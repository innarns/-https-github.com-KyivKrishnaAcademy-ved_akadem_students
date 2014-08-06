require 'spec_helper'

describe 'Signing' do
  describe 'Sign in' do
    Given { create :person, email: 'test@example.com', password: 'password', password_confirmation: 'password' }

    When do
      visit root_path
      click_link 'Sign in'
      fill_in 'person_email', with: 'test@example.com'
      fill_in 'person_password', with: 'password'
      click_button 'Sign in'
    end

    Then { find('.alert-notice').should have_content('Вхід успішний.') }
  end
end