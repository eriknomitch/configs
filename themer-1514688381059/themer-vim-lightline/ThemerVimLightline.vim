

  
  if &background == 'dark'
    
  let s:shade0 = "#282629"
  let s:shade1 = "#474247"
  let s:shade2 = "#656066"
  let s:shade3 = "#847E85"
  let s:shade4 = "#A29DA3"
  let s:shade5 = "#C1BCC2"
  let s:shade6 = "#E0DCE0"
  let s:shade7 = "#FFFCFF"
  let s:accent0 = "#FF4050"
  let s:accent1 = "#F28144"
  let s:accent2 = "#FFD24A"
  let s:accent3 = "#A4CC35"
  let s:accent4 = "#26C99E"
  let s:accent5 = "#66BFFF"
  let s:accent6 = "#CC78FA"
  let s:accent7 = "#F553BF"
  
  endif
  

  
  if &background == 'light'
    
  let s:shade0 = "#FFFCFF"
  let s:shade1 = "#E0DCE0"
  let s:shade2 = "#C1BCC2"
  let s:shade3 = "#A29DA3"
  let s:shade4 = "#847E85"
  let s:shade5 = "#656066"
  let s:shade6 = "#474247"
  let s:shade7 = "#282629"
  let s:accent0 = "#F03E4D"
  let s:accent1 = "#F37735"
  let s:accent2 = "#EEBA21"
  let s:accent3 = "#97BD2D"
  let s:accent4 = "#1FC598"
  let s:accent5 = "#53A6E1"
  let s:accent6 = "#BF65F0"
  let s:accent7 = "#EE4EB8"
  
  endif
  

  let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
  let s:p.normal.left = [ [ s:shade1, s:accent5 ], [ s:shade7, s:shade2 ] ]
  let s:p.normal.right = [ [ s:shade1, s:shade4 ], [ s:shade5, s:shade2 ] ]
  let s:p.inactive.right = [ [ s:shade1, s:shade3 ], [ s:shade3, s:shade1 ] ]
  let s:p.inactive.left =  [ [ s:shade4, s:shade1 ], [ s:shade3, s:shade0 ] ]
  let s:p.insert.left = [ [ s:shade1, s:accent3 ], [ s:shade7, s:shade2 ] ]
  let s:p.replace.left = [ [ s:shade1, s:accent1 ], [ s:shade7, s:shade2 ] ]
  let s:p.visual.left = [ [ s:shade1, s:accent6 ], [ s:shade7, s:shade2 ] ]
  let s:p.normal.middle = [ [ s:shade5, s:shade1 ] ]
  let s:p.inactive.middle = [ [ s:shade4, s:shade1 ] ]
  let s:p.tabline.left = [ [ s:shade6, s:shade2 ] ]
  let s:p.tabline.tabsel = [ [ s:shade6, s:shade0 ] ]
  let s:p.tabline.middle = [ [ s:shade2, s:shade4 ] ]
  let s:p.tabline.right = copy(s:p.normal.right)
  let s:p.normal.error = [ [ s:accent0, s:shade0 ] ]
  let s:p.normal.warning = [ [ s:accent2, s:shade1 ] ]

  let g:lightline#colorscheme#ThemerVimLightline#palette = lightline#colorscheme#fill(s:p)

  