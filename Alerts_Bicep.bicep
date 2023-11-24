param status string = 'Active'

@description('Specify the email address where the alerts are sent to.')
param emailAddress string

@description('Specify the email address name where the alerts are sent to.')
param emailName string 

resource emailActionGroup 'microsoft.insights/actionGroups@2021-09-01' = {
  name: 'emailActionGroupName'
  location: 'global'
  properties: {
    groupShortName: 'string'
    enabled: true
    emailReceivers: [
      {
        name: emailName
        emailAddress: emailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

resource alert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'alertResource'
  location: 'global'
  properties: {
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ResourceHealth'
        }
        {
          field: 'status'
          equals: status
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: emailActionGroup.id
        }
      ]
    }
  }
}


resource alertProcessingRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'alertMonitorService'
  location: 'global'
  properties: {
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          emailActionGroup.id
        ]
      }
    ]
    conditions: [
      {
        field: 'MonitorService'
        operator: 'Equals'
        values: [
          'Azure Backup'
        ]
      }
    ]
    enabled: true
    scopes: [
      subscription().id
    ]
  }
}
