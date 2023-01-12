
import os
import requests
import time
import urllib3

def debug_request_result(result):
  print('Request Result: %s' % result.text)
  print('Request Status Code: %s' % result.status_code)

def main():

  # Disable cert warnings for urllib3/requests
  urllib3.disable_warnings()

  # Check for mandatory environment vars
  envvars = [
    'ELASTIC_USERNAME',
    'ELASTIC_PASSWORD',
    'KIBANA_USERNAME',
    'KIBANA_PASSWORD',
    'ELASTIC_HOST',
    'ELASTIC_PORT',
    'KIBANA_HOST',
    'KIBANA_PORT'
  ]

  for item in envvars:
    value = os.environ.get(item)
    if value is None or value == "":
      raise Exception('Missing environment var: %s' % item)

  # Authentication for elastic and kibana
  elastic_auth = (os.environ.get('ELASTIC_USERNAME'), os.environ.get('ELASTIC_PASSWORD'))
  kibana_auth = (os.environ.get('KIBANA_USERNAME'), os.environ.get('KIBANA_PASSWORD'))

  # Base URIs for connectivity
  elastic_check_uri = 'https://%s:%s/_cat/health?format=json' % (os.environ.get('ELASTIC_HOST'), os.environ.get('ELASTIC_PORT'))
  kibana_check_uri = 'https://%s:%s/api/features' % (os.environ.get('KIBANA_HOST'), os.environ.get('KIBANA_PORT'))

  # requests sessions
  elastic_session = requests.Session()
  elastic_session.auth = elastic_auth
  elastic_session.verify = False
  elastic_session.headers = {
    "Content-Type": "application/json"
  }

  kibana_session = requests.Session()
  kibana_session.auth = kibana_auth
  kibana_session.verify = False
  kibana_session.headers = {
    "Content-Type": "application/json"
  }

  attempt = 1
  while True:
    # Attempt to connect to the elastic environment
    print('Elastic connection attempt: %s' % attempt)
    try:
      print('Checking elastic connectivity')
      elastic_result = elastic_session.get(elastic_check_uri)
      debug_request_result(elastic_result)

      print('Checking kibana connectivity')
      kibana_result = elastic_session.get(kibana_check_uri)
      debug_request_result(kibana_result)

      # Return if we connected and the cluster status is green
      if elastic_result.ok and kibana_result.ok and elastic_result.json()[0]['status'] == 'green':
        return
    except Exception as e:
      print('Could not connect to elastic: %s' % e)

    # Break here if we have tried too many times
    attempt = attempt + 1
    if attempt > 60:
      raise Exception('Could not connect to elastic and exhausted attempts')

    # Wait 30 seconds before trying again
    time.sleep(30)

if __name__ == "__main__":
  main()
