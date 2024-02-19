from X4_Python_Pipe_Server import Pipe_Server
from prometheus_client import start_http_server, Summary, Gauge, Counter
from prometheus_client.core import REGISTRY
import random
import time
import sys
import json
import win32api


# development options
# enable it to write received data to a file
#isDevelopment = False
dataOutputFilename = 'C:\\dev\\x4\\output\\sample-data.txt'
# Max message size in bytes. Should be the same as in node server env file
bufferSize = 262144

#pipe names
pipeInName = 'jbm_metrics'

def main(args):

    print('###: Starting JB Metrics')
    # Configure metrics
    playerCash = Gauge('X4_Player_Cash', 'Current Value of Player Cash')
    x4Time = Counter('X4_Game_Time', 'Current time in X4 Game')

    
    print('###: Attempting to connect to ' + pipeInName + '')
    # start pipe to X4 game
    pipeIn = Pipe_Server(pipeInName, buffer_size = bufferSize)
    pipeIn.Connect()
    print('###: Created '+ pipeInName +' pipe.')
    # Start up the server to expose the metrics we gather. 
    start_http_server(8000)
    gameTime = 0.0

    while 1:
        try: 
            message = pipeIn.Read()
            # Debug output
            print("Received message: " + message)
            f = open(dataOutputFilename, "w", encoding='utf-8')
            f.write(message)
            f.close()
            # Load into metrics
            jsonData = json.loads(message)
            playerCash.set(jsonData['credits'])
            gametimeInc = jsonData['gameTime'] - gameTime
            gameTime = jsonData['gameTime']
            x4Time.inc(gametimeInc)
        except (win32api.error) as ex1:
            REGISTRY.unregister(x4Time)
            REGISTRY.unregister(playerCash)
            raise ex1
        except Exception as ex:
            REGISTRY.unregister(x4Time)
            REGISTRY.unregister(playerCash)
            raise ex
