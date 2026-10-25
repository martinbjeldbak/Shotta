std = 'lua51'
max_line_length = 160

read_globals = {
  'C_EncounterJournal',
  'C_Map',
  'C_Timer',
  'GetRealmName',
  'GetRealZoneText',
  'IsControlKeyDown',
  'IsShiftKeyDown',
  'LibStub',
  'Screenshot',
  'Settings',
  'UIParent',
  'UNKNOWN',
  'UnitName',
  'WOW_PROJECT_BURNING_CRUSADE_CLASSIC',
  'WOW_PROJECT_CLASSIC',
  'WOW_PROJECT_ID',
  'WOW_PROJECT_MAINLINE',
  'WOW_PROJECT_MISTS_CLASSIC',
  'date',
  'format',
  'select',
  'time',
}

exclude_files = {
  'Libs',
}

files['types.lua'] = { ignore = { '631' } }
