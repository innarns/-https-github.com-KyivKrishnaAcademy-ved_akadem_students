require 'rails_helper'

describe AcademicGroupsLoadingInteraction do
  Given(:interaction) { AcademicGroupsLoadingInteraction.new(params: { q: 'шб' }) }

  describe '#as_json' do
    Given!(:right_group) { create :academic_group, title: 'ШБ14-1' }

    Given { create :academic_group, title: 'ШБ13-2', graduated_at: Time.now }
    Given { create :academic_group, title: 'УЧ14-1' }

    Given(:expected) do
      { academic_groups: [{ id: right_group.id,
                            text: right_group.title }] }
    end

    Then { expect(interaction.as_json).to eq(expected) }
  end
end
