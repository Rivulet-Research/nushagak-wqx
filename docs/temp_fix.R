# Read the file
content <- readLines("06_metals_contaminants.qmd")

# Find and replace the metals_freq chunk
new_content <- content

# Replace the line with n_distinct call
new_content <- sub(
  '    Stations = n_distinct\(ResultMeasureValue\),',
  '',
  new_content
)

# Replace the rename line to remove "Unique Sites"
new_content <- sub(
  'rename\("Metal/Element" = CharacteristicName, "Measurements" = Observations, "Unique Sites" = Stations\)',
  'rename("Metal/Element" = CharacteristicName, "Measurements" = Observations)',
  new_content
)

# Write back
writeLines(new_content, "06_metals_contaminants.qmd")
