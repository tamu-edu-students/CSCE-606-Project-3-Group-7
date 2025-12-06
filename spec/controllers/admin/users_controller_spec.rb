require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { User.create!(email: 'admin@tamu.edu', role: 'admin', display_name: 'Admin User') }
  let(:regular_user) { User.create!(email: 'user@tamu.edu', role: 'user', display_name: 'Regular User') }

  describe 'GET #index' do
    context 'when user is admin' do
      before do
        session[:user_id] = admin_user.id
      end

      it 'returns success status' do
        get :index
        expect(response).to have_http_status(:success)
      end

      context 'sorting' do
        let!(:user1) { User.create!(email: 'user1@tamu.edu', role: 'user', display_name: 'User 1', created_at: 2.days.ago) }
        let!(:user2) { User.create!(email: 'user2@tamu.edu', role: 'admin', display_name: 'User 2', created_at: 1.day.ago) }
        let!(:user3) { User.create!(email: 'user3@tamu.edu', role: 'user', display_name: 'User 3', created_at: 3.days.ago) }

        it 'sorts by role (default) - admins first, then users' do
          get :index
          users = assigns(:users).to_a
          # Admins should come first
          expect(users.first(2).map(&:role)).to all(eq('admin'))
          # Then users
          expect(users.last(2).map(&:role)).to all(eq('user'))
        end

        it 'sorts by role then created_at within same role' do
          get :index
          users = assigns(:users).to_a
          # Among admins, newer should come first
          admin_users = users.select { |u| u.role == 'admin' }
          expect(admin_users.first.created_at).to be > admin_users.last.created_at
        end

        it 'sorts by created_at when sort param is provided' do
          get :index, params: { sort: 'created_at' }
          users = assigns(:users).to_a
          # Should be sorted by created_at descending (newest first)
          expect(users.first.created_at).to be > users.second.created_at
          expect(users.second.created_at).to be > users.third.created_at
        end
      end
    end

    context 'when user is not admin' do
      before do
        session[:user_id] = regular_user.id
      end

      it 'redirects to chat path' do
        get :index
        expect(response).to redirect_to(chat_path)
      end

      it 'sets alert message' do
        get :index
        expect(flash[:alert]).to eq('Admin access only')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to chat path' do
        get :index
        expect(response).to redirect_to(chat_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:target_user) { User.create!(email: 'target@tamu.edu', role: 'user', display_name: 'Target User') }

    context 'when user is admin' do
      before do
        session[:user_id] = admin_user.id
      end

      context 'promoting a user to admin' do
        it 'updates the user role to admin' do
          patch :update, params: { id: target_user.id, user: { role: 'admin' } }
          target_user.reload
          expect(target_user.admin?).to be(true)
        end

        it 'redirects to admin users index' do
          patch :update, params: { id: target_user.id, user: { role: 'admin' } }
          expect(response).to redirect_to(admin_users_path)
        end

        it 'sets success flash message' do
          patch :update, params: { id: target_user.id, user: { role: 'admin' } }
          expect(flash[:notice]).to include('granted admin access to')
          expect(flash[:notice]).to include('target@tamu.edu')
        end
      end

      context 'revoking admin access' do
        let(:admin_target) { User.create!(email: 'admintarget@tamu.edu', role: 'admin', display_name: 'Admin Target') }

        it 'updates the user role to user' do
          patch :update, params: { id: admin_target.id, user: { role: 'user' } }
          admin_target.reload
          expect(admin_target.user?).to be(true)
        end

        it 'redirects to admin users index' do
          patch :update, params: { id: admin_target.id, user: { role: 'user' } }
          expect(response).to redirect_to(admin_users_path)
        end

        it 'sets success flash message' do
          patch :update, params: { id: admin_target.id, user: { role: 'user' } }
          expect(flash[:notice]).to include('revoked admin access from')
          expect(flash[:notice]).to include('admintarget@tamu.edu')
        end
      end

      context 'preventing self-demotion' do
        it 'does not allow admin to revoke their own admin access' do
          patch :update, params: { id: admin_user.id, user: { role: 'user' } }
          admin_user.reload
          expect(admin_user.admin?).to be(true)
        end

        it 'redirects with alert message when trying to self-demote' do
          patch :update, params: { id: admin_user.id, user: { role: 'user' } }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to include('cannot revoke your own admin access')
        end
      end

      context 'with invalid role value' do
        it 'rejects invalid role values' do
          patch :update, params: { id: target_user.id, user: { role: 'invalid_role' } }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to eq('Invalid role specified.')
        end

        it 'does not update the user when role is invalid' do
          original_role = target_user.role
          patch :update, params: { id: target_user.id, user: { role: 'super_admin' } }
          target_user.reload
          expect(target_user.role).to eq(original_role)
        end

        it 'rejects nil role values' do
          patch :update, params: { id: target_user.id, user: { role: nil } }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to eq('Invalid role specified.')
        end

        it 'rejects empty string role values' do
          patch :update, params: { id: target_user.id, user: { role: '' } }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to eq('Invalid role specified.')
        end
      end

      context 'with invalid parameters' do
        it 'handles update failures gracefully' do
          # Create a user that will fail validation
          invalid_user = User.new(email: 'invalid@tamu.edu', role: 'user')
          allow(User).to receive(:find).with(target_user.id.to_s).and_return(invalid_user)
          allow(invalid_user).to receive(:update).and_return(false)
          errors = double('errors', full_messages: [ 'Error message' ])
          allow(invalid_user).to receive(:errors).and_return(errors)

          patch :update, params: { id: target_user.id, user: { role: 'admin' } }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to include('Failed to update user')
        end
      end
    end

    context 'when user is not admin' do
      before do
        session[:user_id] = regular_user.id
      end

      it 'redirects to chat path' do
        patch :update, params: { id: target_user.id, user: { role: 'admin' } }
        expect(response).to redirect_to(chat_path)
      end

      it 'sets alert message' do
        patch :update, params: { id: target_user.id, user: { role: 'admin' } }
        expect(flash[:alert]).to eq('Admin access only')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to chat path' do
        patch :update, params: { id: target_user.id, user: { role: 'admin' } }
        expect(response).to redirect_to(chat_path)
      end
    end
  end
end
