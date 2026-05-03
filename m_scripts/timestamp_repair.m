let
    Source = (DateString as text) => 
let
    // Remove day prefix (e.g., "Wed, ")
    RemoveDay = Text.AfterDelimiter(DateString, ", "),
    // Remove "at"
    RemoveAt = Text.Replace(RemoveDay, " at ", " "),
    // Target only the colon followed by the hidden character 8239
    CleanColon = Text.Replace(RemoveAt, ":" & Character.FromNumber(8239), ""),
    // Rebuild the string to handle all years (23, 24, 25, 26)
    SplitParts = Text.Split(CleanColon, " "),
    FixYear = List.ReplaceRange(SplitParts, 2, 1, {"20" & SplitParts{2}}),
    Recombined = Text.Combine(FixYear, " "),
    // Final conversion using US locale
    FinalDate = DateTime.From(Recombined, "en-US")
in
    FinalDate
in
    Source