base:
  '*':
    - vertica
  
  'vertica03':
    - vertica_init
    
  'vertica0[1-2]':
    - vertica_node
