from X4_Python_Pipe_Server import Pipe_Server
import sys

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
    
    print('###: Attempting to connect to ' + pipeInName + '')
    # start pipe to X4 game
    pipeIn = Pipe_Server(pipeInName, buffer_size = bufferSize)
    pipeIn.Connect()
    print('###: Created '+ pipeInName +' pipe.')

    while 1:
        try :
            message = pipeIn.Read()
            print("Received message: " + message)
            f = open(dataOutputFilename, "w", encoding='utf-8')
            f.write(message)
            f.close()
        except Exception:
            tb = sys.exception().__traceback__ 
            print("Error reading pipe.")
                   
