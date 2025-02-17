# README

The spellcheck lib is a tool for finding unrecognized words in a text.

It requires a text to analyze (saved as a .txt file) and a dictionary (also a .txt file with one word per line).

Example output:
```
====================================
--- Running spellcheck ---
------------------------------------
       File: /Users/minniemouse/dev/spellcheck/tmp/text_sample_alpha.txt (2.97 KB)
 Dictionary: /Users/minniemouse/dev/spellcheck/tmp/dictionary.txt (1.66 MB)

--- Reading dictionary file ---
  Found 172,823 words

--- Initializing suggester database ---
--- Clearing existing suggester ---

--- Adding words to suggester ---
  Added 30,000 words: 30,000
  Added 30,000 words: 60,000
  Added 30,000 words: 90,000
  Added 30,000 words: 120,000
  Added 30,000 words: 150,000
  Added 22,823 words: 172,823

  Dictionary initialized with 172,823 words in 3.81 seconds

--- Checking text for unrecognized words ---

    Line           Word   Context / Suggestions
   -----  -------------   ------------------------
       0        Splaaat:  [Splaaat]! Bz nice! The weather
                          ...splat

       0       unusally:  Splaaat! Bz nice! The weather was [unusally] warm for this time of
                          ...unusually

       2        freinds:  reading books or chatting with [freinds]. Even the dogs seemed to
                          ...finds, friends

       3       happilly:  a good mood, wagging their tails [happilly] as they strolled along
                          ...happily

       7              q:  Now for [q] big surprise. No, n huge
                          [no suggestions]

      11          brite:  It was a [brite] and sunny morning when
                          ...blite, barite, bite, boite, bribe, brit, bride, brie, brits, britt, rite, brine, brute, trite, write

      15      embarased:  mulch below. He looked around, [embarased], but soon joined his
                          ...embarrass, embarrassed, embarrasses, embarred, embedded

====================================

Spellcheck completed in 5.82 seconds. It found 7 unrecognized words out of 528 total words.

====================================

```

## Running the Spellchecker
After setup, you execute it from the command line with:
```
rake 'spell:check[{full-path-to-dictionary.txt},{full-path-to-text-to-check.txt}]'
```
For a dictionary stored at:
```
/Users/minniemouse/dev/spellcheck/tmp/dictionary.txt
```
and a text at
```
/Users/minniemouse/dev/spellcheck/tmp/text_sample_alpha.txt
```
the command would be:
```
rake 'spell:check[/Users/minniemouse/dev/spellcheck/tmp/dictionary.txt,/Users/minniemouse/dev/spellcheck/tmp/text_sample_alpha.txt]'
```
### IMPORTANT
Note the single-quotes around 'spell:check[...,...]' and the lack of space between the two file paths. The single quotes are necessary for Zsh. If you're running a different shell you may or may not need the quotes.

## Setup
- Install Ruby version 3.4.1.
- Clone the repo 
- Navigate to the root of the repo
- Install dependencies, initialize the database, and run migrations
```
bundle install
bin/rails db:create
bin/rails db:migrate
```
Run the spellchecker (see above in "Running the Spellchecker").

## Commentary
The order of priority for the features as I developed was:
1. Generate a list of unrecognized words
2. Display the list with context snippets
3. Generate suggestions
4. Handle proper nouns

My conceptual priorities/tradeoffs were:
- Execution Speed: it doesn't have to be instantaneous but it should be pretty fast. (I thought 15 seconds was at the edge of definitely-too-long but 5 seconds seemed okay.)
- Extensibility: this sort of project can expand enormously, so we want it to be pretty clear to the developer where in the code you could add refinements. That is, if we think of a new punctuation combination to mark the end of a sentence or think of a new pattern to search for potential suggestions or a way to handle contractions with more than one apostropher or whatever, we should be able to just add it to the rules and not have to re-write a bunch of stuff. 
- Display Formatting: we don't want to get carried away with formatting, but the first couple of rounds of making the output easier to read have a big payoff in the value of the product. 

The spellchecker holds the entire dictionary in memory and uses the in-memory dictionary to check whether words are in the dictionary or not. It also loads the entire dictionary into a database table and uses the database table for generating suggestions. I don't love the redundancy but the dictionary is small enough that it fits in memory fine and is faster (Ruby sets are O(1) for lookups and the set is in memory so we don't have to go to the database). 
