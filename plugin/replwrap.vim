if !has('python3')
	finish
endif

python3 << EOF
from websocket import create_connection
import vim
#ws = create_connection("ws://localhost:60999/")
hostname = "localhost"
hostport = "60999"
host = "ws://"+hostname+":"+hostport
EOF

function! ReplwrapSetPort(port)
python3 << EOF
host = "ws://"+hostname+":"+vim.eval("a:port")
EOF
endfunc
function! ReplwrapSetHostname(hostname)
python3 << EOF
host = "ws://"+vim.eval("a:hostname")+":"+hostport
EOF
endfunc
function! ReplwrapSetHost(host)
python3 << EOF
host = vim.eval("a:host")
EOF
endfunc

function! ReplwrapConnect(host)
  "let s:path = expand('<sfile>:p')
  "py3file replwrap.py

python3 << EOF
#from websocket import create_connection
ws = create_connection(vim.eval("a:host"))
#import websocket

#def on_message(ws, message):
#    print(message)
#
#def on_error(ws, error):
#    print(error)
#
#def on_close(ws):
#    print("### closed ###")
#
#def on_open(ws):
#    print("socket opened")
#
## websocket.enableTrace(True)
#ws = websocket.WebSocketApp("ws://localhost:60999/",
#                            on_message=on_message,
#                            on_error=on_error,
#                            on_close=on_close)
#ws.on_open = on_open
##ws.run_forever()
#
EOF
endfunc


function! ReplwrapSendCurrentLine()
python3 << EOF
ws = create_connection(host)
ws.send(vim.current.line)
#ws.recv()
#print(vim.current.line)
print("sent to repl")
EOF
endfunc

function! ReplwrapSendCurrentSelection() range
python3 << EOF
ws = create_connection(host)
buf = vim.current.buffer
(lnum1, col1) = buf.mark('<')
(lnum2, col2) = buf.mark('>')
lines = vim.eval('getline({}, {})'.format(lnum1, lnum2))
lines[0] = lines[0][col1:]
lines[-1] = lines[-1][:col2+1]
lines = "\n".join(lines)
ws.send(lines)
print("sent to repl")
EOF
endfunc

"command! -nargs=0 ReplwrapConnect call ReplwrapConnect()
nmap <space> :call ReplwrapSendCurrentLine()<cr>
vmap <space> :call ReplwrapSendCurrentSelection()<cr>

"call ReplwrapConnect()
autocmd BufEnter *.clj,*.cljc call ReplwrapSetPort("60999")
autocmd BufEnter *.py call ReplwrapSetPort("61000")
autocmd BufEnter *.js call ReplwrapSetPort("61001")
