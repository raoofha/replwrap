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
host = "ws://"+vim.eval("a:host")
EOF
endfunc

function! s:ReplwrapSendCurrentLine()
python3 << EOF
ws = create_connection(host)
ws.send(vim.current.line)
#ws.recv()
#print(vim.current.line)
print("sent to repl")
EOF
endfunc

function! s:ReplwrapSendCurrentSelection() range
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


let fireplace#skip = 'synIDattr(synID(line("."),col("."),1),"name") =~? "comment\\|string\\|char\\|regexp"'
function! s:ReplwrapCurrentForm() abort
  let sel_save = &selection
  let cb_save = &clipboard
  let reg_save = @@
  try
    set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
    let open = '[[{(]'
    let close = '[]})]'
    if getline('.')[col('.')-1] =~# close
      let [line1, col1] = searchpairpos(open, '', close, 'bn', g:fireplace#skip)
      let [line2, col2] = [line('.'), col('.')]
    else
      let [line1, col1] = searchpairpos(open, '', close, 'bcn', g:fireplace#skip)
      let [line2, col2] = searchpairpos(open, '', close, 'n', g:fireplace#skip)
    endif
    while col1 > 1 && getline(line1)[col1-2] =~# '[#''`~@]'
      let col1 -= 1
    endwhile
    call setpos("'[", [0, line1, col1, 0])
    call setpos("']", [0, line2, col2, 0])
    silent exe "normal! `[v`]y"
    redraw
python3 << EOF
ws = create_connection(host)
ws.send(vim.eval("@@"))
print("sent to repl")
EOF
  finally
    let @@ = reg_save
    let &selection = sel_save
    let &clipboard = cb_save
  endtry
endfunction

au FileType python,javascript nmap <space> :call <SID>ReplwrapSendCurrentLine()<cr>
au FileType clojure nmap <space> :call <SID>ReplwrapCurrentForm()<cr>
au FileType clojure,python,javascript vmap <space> :call <SID>ReplwrapSendCurrentSelection()<cr>

autocmd BufEnter *.clj,*.cljc,*.cljs call ReplwrapSetPort("60999")
autocmd BufEnter *.py call ReplwrapSetPort("61000")
autocmd BufEnter *.js call ReplwrapSetPort("61001")
