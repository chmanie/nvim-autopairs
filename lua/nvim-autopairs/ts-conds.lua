local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

local log = require('nvim-autopairs._log')
local parsers = require'nvim-treesitter.parsers'
local utils = require('nvim-autopairs.utils')

local conds = {}

conds.is_endwise_node = function(nodes)
    if type(nodes) == 'string' then nodes = {nodes} end
    assert(nodes ~= nil, "ts nodes should be string or table")

    return function (opts)
        log.debug('is_endwise_node')
        if not opts.check_endwise_ts then return true end
        if #nodes == 0 then return true end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            local text = ts_utils.get_node_text(target) or {""}
            local last = text[#text]:match(opts.rule.end_pair)
            -- check last character is match with end_pair
            if last == nil then
                return true
            end
                log.debug('last:' .. last)
                -- if match then we need tocheck parent node
                local _,_, linenr_target = target:range()
                local _,_, linenr_parent = target:parent():range()
                -- log.debug(target:range())
                -- log.debug(ts_utils.get_node_text(target))
                -- log.debug(target:parent():range())
                -- log.debug(ts_utils.get_node_text(target:parent()))
                if linenr_parent - linenr_target == 1 then
                    return true
                end
            else
        end
        return false
    end
end

conds.is_ts_node = function(nodes)
    if type(nodes) == 'string' then nodes = {nodes} end
    assert(nodes ~= nil, "ts nodes should be string or table")
    return function (opts)
        log.debug('is_ts_node')
        if not opts.ts_node then return end
        if #nodes == 0 then return  end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            return true
        end
    end
end

conds.is_not_ts_node = function(nodes)
    if type(nodes) == 'string' then nodes = {nodes} end
    assert(nodes ~= nil, "ts nodes should be string or table")
    return function (opts)
        log.debug('is_not_ts_node')
        if not opts.ts_node then return end
        if #nodes == 0 then return  end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            return false
        end
    end
end

conds.is_not_ts_node_comment = function()
    return function(opts)
        log.debug('not_in_ts_node_comment')
        if not opts.ts_node then return end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        log.debug(target:type())
        if target ~= nil and utils.is_in_table(opts.ts_node, target:type()) then
            return false
        end
    end
end

return conds
