local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return {
    -- ==========================================
    -- 1. HEADERS & BOILERPLATE
    -- ==========================================

    -- MAIN function
    -- Fix: Escape <stdio.h> to <<stdio.h>>
    s({trig = "main", snippetType="autosnippet"}, fmta(
        [[
        #include <<stdio.h>>
        #include <<stdlib.h>>

        int main(int argc, char *argv[]) {
            <>

            return 0;
        }
        ]],
        { i(0) }
    )),

    -- INCLUDE (standard) -> #include <...>
    s({trig = "inc", snippetType="autosnippet"}, fmta(
        "#include <<<> >>",
        { i(1) }
    )),

    -- INCLUDE (local) -> #include "..."
    s({trig = "Inc", snippetType="autosnippet"}, fmta(
        '#include "<>"',
        { i(1) }
    )),

    -- HEADER GUARD (Include Guard)
    s({trig = "once", snippetType="autosnippet"}, fmta(
        [[
        #ifndef <>
        #define <>

        <>

        #endif /* <> */
        ]],
        { i(1, "HEADER_H"), rep(1), i(0), rep(1) }
    )),

    -- ==========================================
    -- 2. I/O (Printing & Scanning)
    -- ==========================================

    -- PRINTF
    -- Note: \\n is needed to output a literal \n in the string
    s({trig = "pr", snippetType="autosnippet"}, fmta(
        'printf("<>\\n"<>);',
        { i(1), i(0) }
    )),

    -- FPRINTF (File Print)
    s({trig = "fpr", snippetType="autosnippet"}, fmta(
        'fprintf(<>, "<>\\n"<>);',
        { i(1, "stderr"), i(2), i(0) }
    )),

    -- SCANF
    s({trig = "sc", snippetType="autosnippet"}, fmta(
        'scanf("<>", &<>);',
        { i(1, "%d"), i(2) }
    )),

    -- ==========================================
    -- 3. CONTROL FLOW
    -- ==========================================

    -- FOR LOOP
    -- Fix: Escape comparison operator < to <<
    s({trig = "fori", snippetType="autosnippet"}, fmta(
        [[
        for (int <> = 0; <> << <>; ++<>) {
            <>
        }
        ]],
        { i(1, "i"), rep(1), i(2, "n"), rep(1), i(0) }
    )),

    -- WHILE LOOP
    s({trig = "wh", snippetType="autosnippet"}, fmta(
        [[
        while (<>) {
            <>
        }
        ]],
        { i(1), i(0) }
    )),

    -- DO WHILE
    s({trig = "dow", snippetType="autosnippet"}, fmta(
        [[
        do {
            <>
        } while (<>);
        ]],
        { i(0), i(1) }
    )),

    -- IF STATEMENT
    s({trig = "if", snippetType="autosnippet"}, fmta(
        [[
        if (<>) {
            <>
        }
        ]],
        { i(1), i(0) }
    )),

    -- ELSE IF
    s({trig = "elif", snippetType="autosnippet"}, fmta(
        [[
        else if (<>) {
            <>
        }
        ]],
        { i(1), i(0) }
    )),

    -- ELSE
    s({trig = "el", snippetType="autosnippet"}, fmta(
        [[
        else {
            <>
        }
        ]],
        { i(0) }
    )),

    -- SWITCH
    s({trig = "sw", snippetType="autosnippet"}, fmta(
        [[
        switch (<>) {
            case <>:
                <>
                break;
            default:
                break;
        }
        ]],
        { i(1), i(2), i(0) }
    )),

    -- ==========================================
    -- 4. TYPES & DATA STRUCTURES
    -- ==========================================

    -- TYPEDEF STRUCT (The idiomatic C struct)
    s({trig = "ts", snippetType="autosnippet"}, fmta(
        [[
        typedef struct <> {
            <>
        } <>;
        ]],
        { i(1, "Name"), i(0), rep(1) }
    )),

    -- STRUCT (Basic)
    s({trig = "st", snippetType="autosnippet"}, fmta(
        [[
        struct <> {
            <>
        };
        ]],
        { i(1, "Name"), i(0) }
    )),

    -- ENUM
    s({trig = "enum", snippetType="autosnippet"}, fmta(
        [[
        typedef enum {
            <>
        } <>;
        ]],
        { i(0), i(1, "EnumName") }
    )),

    -- ==========================================
    -- 5. FUNCTIONS & POINTERS
    -- ==========================================

    -- FUNCTION DEFINITION
    s({trig = "fun", snippetType="autosnippet"}, fmta(
        [[
        <> <>(<>) {
            <>
            return <>;
        }
        ]],
        { i(1, "void"), i(2, "function_name"), i(3), i(0), i(4, "0") }
    )),

    -- MALLOC
    -- Generates: int* ptr = malloc(sizeof(int) * size);
    s({trig = "mall", snippetType="autosnippet"}, fmta(
        "<>* <> = malloc(sizeof(<>) * <>);",
        { i(1, "type"), i(2, "ptr"), rep(1), i(3, "1") }
    )),

    -- CALLOC (Zero initialized)
    s({trig = "call", snippetType="autosnippet"}, fmta(
        "<>* <> = calloc(<>, sizeof(<>));",
        { i(1, "type"), i(2, "ptr"), i(3, "count"), rep(1) }
    )),
}
