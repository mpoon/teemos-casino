# Allow us to use ejs and erb for the same file
# http://stackoverflow.com/a/9282744
# EJS.evaluation_pattern    = /\{\{([\s\S]+?)\}\}/
# EJS.interpolation_pattern = /\{\{=([\s\S]+?)\}\}/
# Use patterns that don't match anything--we don't actually
# want EJS functionality other than wrapping our HTML to
# be parsed by JST, and we use ERB templating otherwise
EJS.evaluation_pattern    = /a^/
EJS.interpolation_pattern = /a^/
