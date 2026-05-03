M-Language Timestamp Repair
Project Goal: Resolving "DataFormat.Error" in Power BI caused by hidden Unicode 8239 artifacts in modern web service exports.

Overview
This repository contains a specialized Power Query (M) script designed to sanitize and parse complex date strings. This is a common issue for data exported from modern SaaS platforms using updated Java (JDK 20+) or ICU library formatting.

Technical Report: Date Column Transformation & Audit
### 1. The Problem
The Date column (e.g., Wed, Feb 1, 23 at 1:55: AM) was imported as a text string. Standard attempts to convert this to a "Date/Time" type in Power BI consistently failed with a DataFormat.Error. Manual fixes, such as replacing the word "at" and removing visible extra colons, did not resolve the issue, suggesting a hidden encoding problem within the string metadata.

### 2. Identifying the "Invisible" Culprit
To identify why the system was still rejecting the data, I conducted a digital audit using Power Query's internal "microscope" functions:

The Length Test: I utilized Text.Length and discovered the string was physically longer than it appeared on screen, confirming the existence of "ghost" characters.

Deconstruction: I used Text.ToList to break the string into individual characters.

The Unicode Audit: I applied the Character.ToNumber function to that list. Because I initially encountered a "Type Mismatch" error, I structured a List.Transform formula to map the IDs correctly.

The Discovery: The audit revealed Unicode 8239 (a Narrow No-Break Space) hiding immediately after the colon. This character is not a standard keyboard space (code 32), which causes the standard Power BI date parser to fail.

### 3. AI Collaboration & Troubleshooting
Since I am not an expert in M Language (Power Query’s functional syntax), I used an AI as a technical bridge. This was an iterative, collaborative process:

Reporting Findings: I provided the AI with the specific Unicode ID (8239) and the identified patterns.

Refinement: I instructed the AI to provide a "surgical" version that wouldn't accidentally damage other parts of the string.

Result: The AI provided an advanced script that "rebuilds" the date string accurately, handling the years 2023 through 2026 dynamically.

### 4. The Solution (Implemented Code)
The following script was implemented to clean the data and perform the type conversion:
```powerquery
try 
    let
        SourceText = [Date],
        // Remove day prefix (e.g., "Wed, ")
        RemoveDay = Text.AfterDelimiter(SourceText, ", "),
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
otherwise 
    null
 ```

### 5. Troubleshooting & Adaptability**
This solution is modular and can be adjusted if the data export format changes:

*   **Global Sanitization:** To target a hidden character anywhere in the string (regardless of what characters are next to it), use:  
    `Text.Replace(SourceText, Character.FromNumber(8239), " ")`

*   **Targeting Other Artifacts:** If your audit reveals a different Unicode ID (e.g., `160` for a non-breaking space), simply update the numeric value within the `Character.FromNumber()` function.

### 6. Conclusion
By combining manual forensic investigation with AI-assisted coding, I successfully transformed a corrupted dataset into a reliable format. This ensures that the report now supports all Time Intelligence features and automated date hierarchies in Power BI.