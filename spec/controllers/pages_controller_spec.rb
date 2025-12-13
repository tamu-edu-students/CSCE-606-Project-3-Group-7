require 'rails_helper'

class PagesController < ApplicationController
  def home
    @message_count = Message.count
  end
end
