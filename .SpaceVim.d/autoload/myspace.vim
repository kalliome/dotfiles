function! myspace#before() abort
  let g:spacevim_project_rooter_patterns = ['.rootdir']
  let g:ctrlp_root_markers = ['.rootdir']
  let g:ctrlp_working_path_mode = 0
  
  let g:user_emmet_leader_key = ','
  let g:user_emmet_settings = {
  \  'javascript' : {
  \   'extends': 'jsx'
  \  }
  \}

endfunction

function! myspace#after() abort
  let g:vimfiler_ignore_pattern = '^\.git\|node_modules\|.DS_Store'
  let g:spacevim_project_rooter_patterns = ['.rootdir']
  
endfunction

