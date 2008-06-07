require File.dirname(__FILE__) + '/../test_helper'

class UserOpenidTest < ActiveSupport::TestCase

  def test_normalized_url
    urls = [
      ['http://nicwilliams.myopenid.com/', 'http://nicwilliams.myopenid.com/'],
      ['http://drnicwilliams.com', 'http://drnicwilliams.com/'],
      ['drnic.myopenid.com', 'http://drnic.myopenid.com/']
      ]
    urls.each do |orig, expected|
      user_openid = UserOpenid.create :user_id => 1, :openid_url => orig
      assert_equal(expected, user_openid.openid_url)
    end
  end

  def test_denormalized_url
    urls = [
      ['http://nicwilliams.myopenid.com/', 'nicwilliams.myopenid.com'],
      ['http://drnicwilliams.com', 'drnicwilliams.com'],
      ['drnic.myopenid.com', 'drnic.myopenid.com']
      ]
    urls.each do |orig, expected|
      user_openid = UserOpenid.create :user_id => 1, :openid_url => orig
      assert_equal(expected, user_openid.denormalized_url)
    end
  end
end
