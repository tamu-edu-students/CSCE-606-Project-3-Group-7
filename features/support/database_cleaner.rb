# DatabaseCleaner hooks for Cucumber
Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
