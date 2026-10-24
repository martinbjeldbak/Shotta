std = 'lua51'
max_line_length = 160

read_globals = {
  'C_Timer',
  'IsControlKeyDown',
  'IsShiftKeyDown',
  'LibStub',
  'Screenshot',
  'Settings',
  'UIParent',
  'WOW_PROJECT_BURNING_CRUSADE_CLASSIC',
  'WOW_PROJECT_CLASSIC',
  'WOW_PROJECT_ID',
  'WOW_PROJECT_MAINLINE',
  'WOW_PROJECT_MISTS_CLASSIC',
  'date',
  'format',
  'time',
}

exclude_files = {
  'Libs',
}

files['types.lua'] = { ignore = { '631' } }
