-- ===============================================
-- COLORS->BLUEGREEN =============================
-- ===============================================
local Color, colors, Group, groups, styles = require('colorbuddy').setup()

-- " -----------------------------------------------
-- " PALETTE ----------------------------------------
-- " ------------------------------------------------
Color.new('background_0', '#000000')
Color.new('foreground', '#FFFFFF')

Color.new('primary', '#67FF68')
Color.new('primary_dark', '#1EC703')
Color.new('primary_darker', '#1FB7B7')
Color.new('primary_special', '#6DFFB5')

Color.new('secondary', '#6868FF')
Color.new('secondary_light', '#7D29EE')
Color.new('secondary_lighter', '#945AE2')
Color.new('secondary_dark', '#4D21ED')
Color.new('secondary_special', '#685E79')

Color.new('error', '#FF2B2B', nil, styles.bold)
Color.new('error_light', '#FF4C4C')

Color.new('active', '#8736ff')
Color.new('attention', '#5AFA6E') -- same as tmux
