return {
    'mfussenegger/nvim-dap-python', -- debug configuration for py
    build = ':TSInstall python',
    config = function ()
        require('dap-python').setup('~/.virtualenvs/debugpy/bin/python') -- system python, requires `pip install debugpy`
    end
}
