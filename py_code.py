a = ldap3.Server('ldaps://ad.com')
with ldap3.Connection(server=a, user=user, password=pwd) as conn:
   count = 0
   while len(res_mem) is 0:
       print(count)
       ad_search = f'(objectClass=grouop)(CN={escape_filter_chars(dict_key)})'
       search_base = sub_tree_list[count]
       conn.seearch(search_base, ad_search, attributes=]'member'])
       if conn.entries:
           for member in conn.entries[0]['member']:
               cn = str(member).index('CN=')
               end_index = str(member).index(',')
               member_id = str(member)[cn+len('CN='):end_index].upper()
               res.append(member_id)
       else:
          print('Unsuccess')



s, res, resp, _ = conn.search(
  'DC=center,DC=ad,DC=com',
  '(CN=abc)',
  search_scope=ldap3.SUBTREE,
  attributes=[*]
)



def cronmock():
  print('Started: ', time.strftime('%H:%M %Z', time.gmtime()))
  if time.strftime('%H:%M %Z', time.gmtime()).find('East'):
    print(time.strftime('%H:%M %Z', time.gmtime()).find('East'))
  else:
    re.search('East', time.strftime('%H:%M %Z', time.gmtime()).find('East'))
    
sch = BackgroundScheduler(daemon=True)
sch.add_job(cronmock, 'interval', seconds=5)
sch.start()



class Query(graphene.ObjectType):
  graphqlstr = graphqlq
  q = graphene.String(name-graphene.String(Default_value=graphqlq))
  def resolve(self, info, name):
    return name

class Graphql:
  def __init__(self):
    self.cursor = str()
    self.syntax = {'data': {'apps': {'edges': []}}}
  def createq(self):
    query = """
query apps {
  FApps(filter: {lob : 'mylob'}, first 100""" + self.cursor + """) {
    pageInfo {
      hasPreviousPage
      startCursor
    }
    edges {
      node {
        name
        foundation {
          region
          pool
          env
        }
        space {
          guid
          name
          org {
            guid
            name
          }
        }
        app {
          owner
          appId
          contacts {
            person {
              FullName
            }
          }
        }
        state
        instances
        memory
        updated
      }
    cursor
    }
    pageInfo {
      endCursor
      hasNextPage
    }
  }
}
"""



#!/usr/bin/python
import re
import json
import jira
import base64
import requests

### Issue Priority Table ###
# 'id': '4'      # AWMCCA -> Low
# 'id': '10101'  # AWMCCA -> Medium
# 'id': '10100'  # AWMCCA -> High
# 'id': '10203'  # AWMCCA -> Regulatory
# 'id': '10205'  # AWMCCA -> Emergency
# 'id': '10006'  # TOMSE -> Trivial
# 'id': '10008'  # TOMSE -> Minor
# 'id': '4'      # TOMSE -> Low
# 'id': '3'      # TOMSE -> Medium
# 'id': '2'      # TOMSE -> High
# 'id': '10000'  # TOMSE -> Urgent
# 'id': '10005'  # TOMSE -> Showstopper
# 'id': '4'      # AWMCLOUD -> Low
# 'id': '10101'  # AWMCLOUD -> Medium
# 'id': '10100'  # AWMCLOUD -> High
# 'id': '10205'  # AWMCLOUD -> Emergency
# 'id': '10203'  # AWMCLOUD -> Regulatory

issuePriDict = {
    'AWMCCA': {
        'Low':        4,
        'Medium':     10101,
        'High':       10100,
        'Regulatory': 10203,
        'Emergency':  10205
    },
    'TOMSE': {
        'Trivial':     10006,
        'Minor':       10008,
        'Low':         4,
        'Medium':      3,
        'High':        2,
        'Urgent':      10000,
        'Showstopper': 10005
    },
    'AWMCLOUD': {
        'Low':         4,
        'Medium':      10101,
        'High':        10100,
        'Emergency':   10205,
        'Regulatory':  10203,
    }
}

############################

### Issue Type Table ###
# AWMCCA
# 'id': '10507'  # -> Initiative
# TOMSE
# 'id': '10213'  # -> Task
# 'id': '10217'  # -> userStory
# 'id': '10216'  # -> useCase
# 'id': '10204'  # -> enhancementRequest
# AWMCLOUD
# 'id': '10505'  # -> Story

issType = {
    'AWMCCA': {
        'Initiative':           10507
    },
    'TOMSE': {
        'Task':                 10213,
        'User Story':           10217,
        'Use Case':             10216,
        'Enhancement Requests': 10204
    },
    'AWMCLOUD': {
        'Story':                10505
    }
}
########################

### Fix Versions Object Table ###
# 'id': '11802'  # -> GAP
# 'id': '11800'  # -> GKP
# 'id': '23600'  # -> GAIA
# 'id': '11803'  # -> GOS
# 'id': '12100'  # -> GSaaS(ElasticSearch)

issLabOrFV = {
    'GAP':                  11802,
    'GKP':                  11800,
    'GAIA':                 23600,
    'GOS':                  11803,
    'GSaaS(ElasticSearch)': 12100
}

#################################

# Syntax: '<user>:<password>'
user = 'F632830:<password>'  # TODO update when needed
encodedBytes = base64.b64encode(user.encode("utf-8"))
encodedStr = str(encodedBytes, "utf-8")


# Can have multiple items, jira Issue(s) here. No need to change JQl if this var is set. TODO: ENSURE LIST TYPE!!!
cil = ['abc123-1035']  # TODO update when needed
#  Default fields are key, summary, and description, additional fields are updated later
query = {"jql": "CHANGEME", "fields": "key, summary, description", "startAt": "0"}

headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Basic ' + encodedStr,  # Specify auth type in module
    'cache-control': "no-cache"
}

# User Variables
tproj = 'TOMSE'       # <JIRA Project: key='TOMSE', name='TOMSE', id='52507'>  # (Retrieved with jira.client.JIRA())
tid = '52507'         # From print(jira.client.Jira(<server>).projects())
awmproj = 'abc123'    # <JIRA Project: key='abc123', name='name', id='10705'>  # (Retrieved with jira.client.JIRA())
aid = '10705'         # From print(jira.client.Jira(<server>).projects())
awmcloud = 'abc567' # <JIRA Project: key='abc567', id='10812'>  # (Retrieved with jira.client.JIRA())
awmc = '10812'        # From print(jira.client.Jira(<server>).projects())

# TOMSE urls
urlt = "https://jira.com/rest/api/2/issue"             # NOTE: '/issue' AT THE END
urltsearch = "https://jira.com/rest/api/2/search"      # NOTE: '/issue' AT THE END
urlsprint = "https://jira.com/rest/agile/1.0/sprint/"  # Note: '/' as the tailing character

# AWMCCA/AWMCLOUD urls
urlawmsearch = "https://jira.com/rest/api/2/search"      # NOTE: '/search' AT THE END
urlawmkanban = "https://jira.com/rest/api/2/issue"       # NOTE: '/issue' AT THE END

encodedBytes = base64.b64encode(user.encode("utf-8"))
encodedStr = str(encodedBytes, "utf-8")

headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Basic ' + encodedStr,  # Specify auth type in module
    'cache-control': "no-cache"
}


class jiraCl:
    def __init__(self):
        self.url = str()
        self.data = str()
        self.project = str()
        self.headers = str()
        self.classquery = str()

    def getProjJira(self):
        if self.classquery == '' or self.classquery['jql'] == 'CHANGEME':
            return 'jiraCl.classquery is not proper syntax, please set value or update jql: ' + str(self.classquery)
        return requests.get(
            url=self.url,
            data=self.data,
            headers=self.headers,
            params=self.classquery  # this is class query var
        )

    def __repr__(self):
        return "url: {} ; data: {} ; project: {} ; query: {}".format(self.url, self.data, self.project, self.classquery)


def createNewProjJira(jiraProj, summary, description, urlused, issType, issPriority,
                      assignee=None, *args, **kwargs):

    # https://community.atlassian.com/t5/Answers-Developer-Questions/How-to-add-component-while-creating-an-issue-via-JIRA-REST-API/qaq-p/493660
    queryt = {
        'fields': {
            'project': {
                'id': jiraProj
            },
            'summary': summary,
            'description': description,
            'issuetype': {
                'id': issType
            },
            'priority': {
                'id': str(issPriority)  # Needs type string for jira api call
            },
            'assignee': {
                'name': assignee
            },
            'components': [
                {
                    # 'id': '10916' 
                }
            ]
        }
    }

    for dictKwargs in kwargs:
        queryt['fields'][dictKwargs] = kwargs[dictKwargs]

    jtjira = requests.post(
        url=urlused,
        data=json.dumps(queryt),
        headers=headers
    )

    print("Under project: " + jiraProj + "\nCreated Jira: " + jtjira.text)
    return jtjira.text

def jApiObj(labelOrFixV, queryClassObj, jqlQuery):
    queryClassObj.classquery = jqlQuery  # set query attr in class obj
    indjira = json.loads(queryClassObj.getProjJira().text)
    # print(indjira)  # Displays queried JSON object
    keysum = indjira['issues'][0]['fields']['summary']  # Set issue summary
    keydesc = indjira['issues'][0]['fields']['description']  # Set issue description
    # Set issue label(s)
    keyVList = list()
    if len(indjira['issues'][0]['fields'][labelOrFixV]) == 0:
        exit("Jira " + indjira['issues'][0]['key'] + " does not have a fix version or label, please update.")
    for indFixV in indjira['issues'][0]['fields'][labelOrFixV]:  # Labels are returned list format, FixV are objs
        if labelOrFixV == 'fixVersions':
            keyVList.append(indFixV['name'].upper())
        elif labelOrFixV == 'labels':
            keyVList.append({'id': str(issLabOrFV[indFixV]).upper()})
    return keysum, keydesc, keyVList


def addCurSprint(issid):

    mj = jira.client.JIRA(server='https://jira.com/',
                          basic_auth=(user.split(':')[0], user.split(':')[1]))
    # Get board ID from UI, hover over 'Configure' board link upper right drop-down to see ID number

    # sprint = jira.client.JIRA.sprints(mj, 12794)[-1].raw  # Shows all Sprint related info
    sprint = str(jira.client.JIRA.sprints(mj, 12794)[-1].raw['id'])  # 12794 is board ID
    curquery = {
        'issues': [
            issid
        ]
    }

    addj = requests.post(
        url=urlsprint + sprint + '/issue',
        data=json.dumps(curquery),
        headers=headers
    )

    return addj.text

"""
NOTE: Priority can be found by querying jira:
 json.loads(requests.get(
     url="https://jira.com/rest/api/2/search",
     headers=headers,
     params={"jql": "issue = TOMSE-212", "fields": "key,summary,description,priority"}
 ).text)
"""

# Create class here so not creating new obj for each loop
jiraCl = jiraCl()
jiraCl.headers = headers

""" kwargs usage
    NOTE: Setting 'fixVersions' dict to keyVList forces **kwargs; if "keyVList" is used instead of 
          "fixVersions=keyVList", then object is set to *args not **kwargs, and becomes a Tuple.
"""
for i in cil:
    # TODO, redo below as there is much duplicate code.
    jiraCl.project = i[0].split('-')[0]  # set project val of obj, ex: 'TOMSE'
    query['jql'] = 'issue = ' + str(i)  # set jql value in param query
    if re.search('project', i):
        labelVar = 'fixVersions'
        # Extract jira from project and copy into TOMSE project
        jiraCl.url = urlawmsearch
        query['fields'] = "key, summary, description, " + labelVar
        isssum, issdesc, labelOfFvList = jApiObj(labelVar, jiraCl, query)
        # Create jira w/ params: jiraProject, sum, desc, url, issueType, labels, priority, assignee
        issuekey = createNewProjJira(tid, isssum, issdesc, urlt, issType['TOMSE']['Task'],
                                     issuePriDict['TOMSE']['Medium'], user.split(':')[0],
                                     labels=labelOfFvList)
        # Add issue key to TOMSE current Sprint board ID
        addCurSprint(json.loads(issuekey)['id'])  # Example w/ hardcoded issue key id: addCurSprint('1700886')
    elif re.search('TOMSE', i):
        labelVar = 'labels'
        # Extract jira from TOMSE and copy into project
        jiraCl.url = urltsearch
        query['fields'] = "key, summary, description, " + labelVar
        isssum, issdesc, labelOfFvList = jApiObj(labelVar, jiraCl, query)
        createNewProjJira(aid, isssum, issdesc, urlawmkanban, issType['AWMCCA']['Initiative'],
                          issuePriDict['AWMCCA']['Medium'], user.split(':')[0],
                          fixVersions=labelOfFvList)
    else:
        exit('Project Unrecognized. Currently working on adding project.')

print('Created jira(s) in projects with attributes.')




