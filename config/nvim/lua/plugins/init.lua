-- Ensure lazy is loaded first
require('plugins.lazy')
require("utils").require_all { exclude = { 'plugins.lazy' } }
