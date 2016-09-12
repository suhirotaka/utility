const INSTANCE_TAG_NAME = '__YOUR_INSTANCE_NAME__';
const INSTANCE_MIN_COUNT = 2;
 
var AWS = require('aws-sdk'); 
AWS.config.region = 'ap-northeast-1';
 
var stopEc2Instance = {
  targetInstanceId: '',
  ec2: new AWS.EC2(),
  callback: function(){},

  execute: function(callback) {
    this.callback = callback;

    var describeParams = {
      Filters: [
        {
          Name: 'tag:Name',
          Values: [
            INSTANCE_TAG_NAME
          ]
        },
        {
          Name: 'instance-state-name',
          Values: [
            'running'
          ]
        }
      ]
    }
    this.ec2.describeInstances(describeParams, function(err, data) {
      var launchTime;
      var instanceCount = 0;
      var targetInstanceId;

      if (err) {
        console.log(err, err.stack);
      }else {
        data.Reservations.forEach(function(reservation) {
          reservation.Instances.forEach(function(instance) {
            instanceCount += 1;
            if (!launchTime || instance.LaunchTime < launchTime) {
              launchTime = instance.LaunchTime;
              targetInstanceId = instance.InstanceId;
            }
          });
        });
      }
      if(!targetInstanceId) {
//console.log('No target instance found');
        stopEc2Instance.callback('No target instance found');
      }else if(instanceCount < INSTANCE_MIN_COUNT) {
//console.log('Instance count is under minimum');
        stopEc2Instance.callback('Instance count is under minimum');
      }else {
        console.log('Will stop the EC2 instance whose id is ' + targetInstanceId);
        stopEc2Instance.targetInstanceId = targetInstanceId;
        stopEc2Instance.stop();
      }
    });
  },

  stop: function() {
    var stopParams = {
//DryRun: true,
      InstanceIds: [
        this.targetInstanceId
      ]
    };
    this.ec2.stopInstances(stopParams, function(err, data) {
        if (err) {
          console.log(err, err.stack);
        } else {
//console.log('Successfully  stopped the EC2 instance whose id is ' + stopEc2Instance.targetInstanceId);
          stopEc2Instance.callback(null, 'Successfully  stopped the EC2 instance whose id is ' + stopEc2Instance.targetInstanceId);
        }
    });
  }
}

exports.handler = function(event, context, callback) {
  stopEc2Instance.execute(callback);
};
