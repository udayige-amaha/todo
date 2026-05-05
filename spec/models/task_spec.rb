require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      task = build(:task, user: user)
      expect(task).to be_valid
    end

    it "is not valid without a title" do
      task = build(:task, title: nil, user: user)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it "is not valid with a short title" do
      task = build(:task, title: "Hi", user: user)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("is too short (minimum is 3 characters)")
    end

    it "is not valid with an invalid priority" do
      task = build(:task, priority: 5, user: user)
      expect(task).not_to be_valid
      expect(task.errors[:priority]).to include("is not included in the list")
    end

    it "is not valid without user association" do
      task = build(:task, user: nil)
      expect(task).not_to be_valid
      expect(task.errors[:user]).to include("must exist")
    end
  end

  describe "scopes" do
    it ".overdue returns only past due_date tasks that are not completed" do
      overdue_task = create(:task, due_date: 1.day.ago, completed: false, user: user)
      future_task = create(:task, due_date: 1.day.from_now, completed: false, user: user)
      completed_task = create(:task, due_date: 1.day.ago, completed: true, user: user)

      expect(Task.overdue).to include(overdue_task)
      expect(Task.overdue).not_to include(future_task)
      expect(Task.overdue).not_to include(completed_task)
    end

    it ".by_priority returns tasks ordered by priority" do
      low_priority_task = create(:task, priority: 1, user: user)
      medium_priority_task = create(:task, priority: 2, user: user)
      high_priority_task = create(:task, priority: 3, user: user)

      expect(Task.by_priority).to eq([ high_priority_task, medium_priority_task, low_priority_task ])
    end

    it ".by_due_date returns tasks ordered by due_date" do
      task1 = create(:task, due_date: 3.days.from_now, user: user)
      task2 = create(:task, due_date: 1.day.from_now, user: user)
      task3 = create(:task, due_date: 2.days.from_now, user: user)

      expect(Task.by_due_date).to eq([ task2, task3, task1 ])
    end

    it ".completed returns tasks filtered by completion status" do
      completed_task = create(:task, completed: true, user: user)
      incomplete_task = create(:task, completed: false, user: user)

      expect(Task.completed("true")).to include(completed_task)
      expect(Task.completed("true")).not_to include(incomplete_task)
      expect(Task.completed("false")).to include(incomplete_task)
      expect(Task.completed("false")).not_to include(completed_task)
    end

    it ".by_priority_level returns tasks filtered by priority level" do
      low_priority_task = create(:task, priority: 1, user: user)
      medium_priority_task = create(:task, priority: 2, user: user)
      high_priority_task = create(:task, priority: 3, user: user)

      expect(Task.by_priority_level(1)).to include(low_priority_task)
      expect(Task.by_priority_level(1)).not_to include(medium_priority_task)
      expect(Task.by_priority_level(1)).not_to include(high_priority_task)

      expect(Task.by_priority_level(2)).to include(medium_priority_task)
      expect(Task.by_priority_level(2)).not_to include(low_priority_task)
      expect(Task.by_priority_level(2)).not_to include(high_priority_task)

      expect(Task.by_priority_level(3)).to include(high_priority_task)
      expect(Task.by_priority_level(3)).not_to include(low_priority_task)
      expect(Task.by_priority_level(3)).not_to include(medium_priority_task)
    end
  end
end
