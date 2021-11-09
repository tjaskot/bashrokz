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



