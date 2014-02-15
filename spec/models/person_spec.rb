require 'spec_helper'

describe Person do
  describe "DB table" do
    it { should have_db_column(:name              ).of_type(:string   ) }
    it { should have_db_column(:middle_name       ).of_type(:string   ) }
    it { should have_db_column(:surname           ).of_type(:string   ) }
    it { should have_db_column(:spiritual_name    ).of_type(:string   ) }
    it { should have_db_column(:telephone         ).of_type(:integer  ) }
    it { should have_db_column(:email             ).of_type(:string   ) }
    it { should have_db_column(:gender            ).of_type(:boolean  ) }
    it { should have_db_column(:birthday          ).of_type(:date     ) }
    it { should have_db_column(:emergency_contact ).of_type(:string   ) }
    it { should have_db_column(:photo             ).of_type(:text     ) }
    it { should have_db_column(:profile_fullness  ).of_type(:boolean  ) }
    it { should have_db_column(:edu_and_work      ).of_type(:text     ) }
    it { should have_db_column(:encrypted_password).of_type(:string   ) }
    it { should have_db_column(:username          ).of_type(:string   ) }
  end

  describe "association" do
    it { should have_one(:student_profile).dependent(:destroy) }
    it { should have_and_belong_to_many(:roles) }
  end

  describe "validation" do
    context :password do
      it { should validate_confirmation_of( :password ) }
    end

    context :gender do
      it { should     allow_value(  true, false   ).for(:gender) }
      it { should_not allow_value(  nil           ).for(:gender) }
    end

    context :telephone do
      it { should validate_presence_of(    :telephone ) }
      it { should validate_numericality_of(:telephone ) }
      it { should validate_uniqueness_of(  :telephone ) }
      it { should ensure_inclusion_of(     :telephone )
            .in_range(100_000_000_000..999_999_999_999)
            .with_low_message(  /must be greater than/)
            .with_high_message( /must be less than/   ) }
    end

    context :email do
      INVALID_ADDRESSES = %w[
        user@foo,com     user_at_foo.org
        example.user@foo.foo@bar_baz.com
        foo@bar+baz.com
      ]

      VALID_ADDRESSES   = %w[
        user@foo.COM A_US-ER@f.b.org
        frst.lst@foo.jp   a+b@baz.cn
      ]

      it "allows valid addresses" do
        INVALID_ADDRESSES.each  do |invalid_address|
          should_not  allow_value(invalid_address).for(:email)
        end
      end

      it "disallows invalid addresses" do
        VALID_ADDRESSES.each    do |valid_address|
          should      allow_value(  valid_address).for(:email)
        end
      end

      it "allows empty value" do
        should allow_value('').for(:email)
      end
    end

    context "name, surname, middle_name, spiritual_name" do
      it { should validate_presence_of(:name      ) }
      it { should validate_presence_of(:surname   ) }

      it { should ensure_length_of(:name            ).is_at_most(50) }
      it { should ensure_length_of(:surname         ).is_at_most(50) }
      it { should ensure_length_of(:middle_name     ).is_at_most(50) }
      it { should ensure_length_of(:spiritual_name  ).is_at_most(50) }
    end

    context :username do
      it { should validate_presence_of(   :username ) }
      it { should validate_uniqueness_of( :username ) }
    end
  end

  describe "before save processing" do
    it "downcases :email" do
      create(:person, {email: "A_US-ER@f.B.org"})
        .email.should == "a_us-er@f.b.org"
    end

    it "downcases and titelizes :name, :surname, :middle_name, :spiritual_name" do
      name, surname, mname, spname = 'имЯ', 'фАмИлиЯ', 'ОтчествО', 'АдиДасаДаса ДаС'
      p = FactoryGirl.create(:person,
          name:           name    ,
          surname:        surname ,
          middle_name:    mname   ,
          spiritual_name: spname
        )
      p.name.should           ==  'Имя'
      p.surname.should        ==  'Фамилия'
      p.middle_name.should    ==  'Отчество'
      p.spiritual_name.should ==  'Адидасадаса Дас'
    end

    context "username is blank" do
      it "sets username to email" do
        create(:person, {email: "a@i.ua"})
          .username.should == "a@i.ua"
      end

      it "sets username to telephone if email is blank" do
        create(:person, {email: "", telephone: 380112233444})
          .username.should == "380112233444"
      end
    end

    context "password is blank" do
      it "generates random password" do
        create(:person, {password: "", password_confirmation: ""})
          .encrypted_password.should_not be_blank
      end
    end
  end
end
