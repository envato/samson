require_relative '../test_helper'

describe "slack hooks" do
  let(:deploy) { deploys(:succeeded_test) }
  let(:stage) { deploy.stage }

  describe :before_deploy do
    it "sends notification on before hook" do
      stage.stubs(:send_slack_notifications?).returns(true)
      SlackNotification.any_instance.expects(:deliver)
      Samson::Hooks.fire(:before_deploy, deploy, nil)
    end

    it "does not send notifications when disabled" do
      SlackNotification.any_instance.expects(:deliver).never
      Samson::Hooks.fire(:before_deploy, deploy, nil)
    end
  end

  describe :after_deploy do
    it "sends notification on after hook" do
      stage.stubs(:send_slack_notifications?).returns(true)
      SlackNotification.any_instance.expects(:deliver)
      Samson::Hooks.fire(:after_deploy, deploy, nil)
    end

    it "does not send notifications when disabled" do
      SlackNotification.any_instance.expects(:deliver).never
      Samson::Hooks.fire(:after_deploy, deploy, nil)
    end
  end

  describe :stage_clone do
    it "copies all attributes except id" do
      stage.slack_channels << SlackChannel.new(channel_id: 1, name: 'channel1')
      new_stage = Stage.new
      Samson::Hooks.fire(:stage_clone, stage, new_stage)
      new_stage.slack_channels.map(&:attributes).must_equal [{"id"=>nil, "name"=>"channel1", "channel_id"=>"1", "stage_id"=>nil, "created_at"=>nil, "updated_at"=>nil}]
    end
  end
end
