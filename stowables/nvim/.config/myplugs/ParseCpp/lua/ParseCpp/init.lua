local M = {}

function M.generate_implementation()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = "cpp"
  
  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then print("Error: No C++ parser found."); return end
  local tree = parser:parse()[1]
  local root = tree:root()

  local query_string = [[
    (class_specifier
      name: (type_identifier) @class_name
      body: (field_declaration_list
        (field_declaration
          type: (_) @ret_type
          declarator: (function_declarator
            declarator: (field_identifier) @method_name
            parameters: (parameter_list) @params
          )
        )
      )
    )
  ]]

  local query = vim.treesitter.query.parse(lang, query_string)
  local implementations = {}

  -- Helper: Safely extract text whether 'node' is a single node or a list
  local function safe_get_text(node, source)
    if not node then return nil end
    
    -- If 'node' is a table (list of nodes), use the first one
    -- This fixes the "attempt to call method range" error
    if type(node) == "table" then 
      node = node[1] 
    end

    if not node then return nil end
    return vim.treesitter.get_node_text(node, source)
  end

  -- Iterate Matches
  for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
    local capture_map = {}
    
    -- Build a map of capture_name -> text
    for id, node in pairs(match) do
      local name = query.captures[id]
      capture_map[name] = safe_get_text(node, bufnr)
    end

    local class_name = capture_map["class_name"]
    local ret_type = capture_map["ret_type"]
    local method_name = capture_map["method_name"]
    local params = capture_map["params"]

    if class_name and method_name and ret_type and params then
       -- Clean default params (e.g. "int x = 0" -> "int x")
       local clean_params = params:gsub("%s*=[^,)]+", "")
       
       local impl = string.format("%s %s::%s%s {\n  // TODO: Implement %s\n}\n", 
                                  ret_type, class_name, method_name, clean_params, method_name)
       table.insert(implementations, impl)
    end
  end

  -- Output
  if #implementations == 0 then
    print("No methods found to implement.")
    return
  end

  vim.cmd("vsplit")
  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(new_buf)
  vim.bo.filetype = "cpp"
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(table.concat(implementations, "\n"), "\n"))
end

return M
