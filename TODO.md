- allow filter to be used as either an allow or deny list
  - implement the settings pane with a dropdown to choose
  - use the filter when drawing the baords

# Cleanups
- make it so if you click outside the modal it closes it
- why is the case of the filename for MultiSelect.elm not being recognised properly?
- add Model tests
- add ts declarations to replace @ts-ignores:
    https://github.com/kometenstaub/linked-data-helper/blob/3bbee6aa49bcabd2dab0b8f86bccd2de81ed92e6/src/interfaces.ts#L26
- translator pattern for child -> parent comms ??
  https://medium.com/@alex.lew/the-translator-pattern-a-model-for-child-to-parent-communication-in-elm-f4bfaa1d3f98
- I end up with multiple copies of the app running
  - add a debug to print a string each time update is called
  - in dev mode, open cardboard
  - then close the view
  - then click the ribbon icon
  - you'll see the debug messaged double up
  - and tripple up if you do it again
  - ...

# Task Formats
- https://github.com/schemar/obsidian-tasks
- https://logseq.github.io/#/page/tasks%20%26%20todos
- https://blacksmithgu.github.io/obsidian-dataview/data-annotation/
- https://forum.obsidian.md/t/task-management-devs-add-date-format-standard/26464

# UI Improvements
- nested subtasks are un-nested on cards
  - if I was going to sort this, would I want to support nested autocomplete?
- should I support reverse subtags, i.e. /todo would match #todo or #project1/todo or #a/b/todo
- should I support both ends subtags, i.e. /todo/ would match #todo or #project1/todo or #todo/foo or #a/todo/b
- What should I show on the view when there are no boards defined
- Some sort of toggle compact view - where it shows each task as a single line card
  with only the checkbox and the first line of the title.
- do I want to warn the user that I couldn't read settings at startup?
  are there any sensible options I can give them if I do?
  - gets stuck on "Loading tasks..." if flags parsing fails
  - I could use State if I added a State.Failed
- do I want the last board who's settings I've edited to the one shown when closing settings?
- allow boards to be ordered (in settings somehow - perhaps use this as a first exploration
  into drag and drop?)
- when jumping to the todo using the edit link perhaps I could highlight the complete
  taskItem block (if is has indented content).  Will have to explore the setEphemeralState
  code to see if I can do this using line numbers or whether I need to track characters..
- mobile support?
  - what is it like performance-wise?
  - prob need to use CSS grid more than I am (specially on the settings modal)
- do I want to keep the tabbar in view when horizontal scrolling? (prob yes)
- "spinner" whilst loading tasks (perhaps like in the sidebar when doing searches)
- does openLinkText use setSelection to highlight the selected todo?
  if so, I can do better as by default obsidian doesn't include all
  indented stuff under a todo item as being in the block
- confirm dialog before task deletion
- keyboard navigation
- search for card by title/content
- resizing columns
- what to do about due dates for subtasks
- undo buffer
  - for toggling completion
  - for deletion
- could/should I use some taskpaper tags:
    @defer(date) - defer until date, e.g. 2016-04-19 5pm or next Thursday -3d
    @estimate(time span) - time estimate, e.g. 2h for 2 hours or 3w for 3 weeks.
    @flagged - present when an item is flagged
    @parallel(bool) - whether children are parallel (true) or sequential (false)
    @repeat-method(method) - the repeat method: fixed, start-after-completion, or due-after-completion
    @repeat-rule(rule) - an ICS repeat rule (see RFC244557), e.g. FREQ=WEEKLY;INTERVAL=1
    taskpaper grammer: https://support.hogbaysoftware.com/t/taskpaper-bnf-grammar/4002/3
- edit in place via popup

# Board Improvements
- do I want to sort undated (or other in tagged board) column by the mod date of the containg file?
- do I want a way of flagging cards?
- could make column ordering more efficient (e.g. TagBoard completed tasks)
- context menu to set due date to today
- don't display all completed tasks - can get quite long!
- filter cards on board (e.g. by tag)
- sort order for columns?

# Card Improvements
- specify format for people cards
  - if on line and they contain an image then put the pic on the card
  - support multiple people
- might be cleaner when generating markdown for display on a card to remove the wrapping <p> tag
  intesad of trying to style it's effect away using css
- right click on interal link
- right click on external link
- when clicking the edit button place the cursor at the line of the todo
  have tried to do this using setCursor and not go it to work so far
- display on card - done date

# Theme Compatibility
- Firefly Theme: why is the text so big?
- get working with tabbed view plugin
- bubble space - tags not rendering properly

# Board Types
- have a subtag board that uses a root tag then subtags to define columns
  2 optionss - all leaves or next level (to hadle nested tags)
- reverse subtag: #class1/week1, #class2/week1 (you could specify week1 to get both class 1 & 2 on a board)
- eisenhower matrix view
- #3 define a board from the contents of a file with columns set by the headings on a page

# Drag n Drop
- on a tagboard when drag-dropping allow alt-drag to duplicate the card
  - so maintaining the tag in the column being dragged from as well as getting the new
- multiselect - for drag/drop and context menu operations
- drag and drop
  - into today, tomorrow, and done columns
  - within column to change ordering
- would need a date picker for dragging into (e.g.) future
  suggestion from discord: koala
  31 Oct at 07:52
  https://github.com/TfTHacker/obsidian42-jump-to-date
  https://github.com/liamcain/obsidian-calendar-ui
  For a date picker.

# Misc
- use elm-coverage - as in see what isn't covered
- would it be cleaner to have separate multiselects for each board and share
  the dropdown items?
- I could de-bounce the rewrites of filters in the settings file on rename of path or file
- look at obsidian://show-plugin?id=card-boardw
- do I want to do anything with Alternate Checkboxes?
- supercharged links? - what does it do - does it work with cardBoard?
- do I want to rename Panel -> Board ??
- https://allcontributors.org/docs/en/overview
- how small can I make the compliled js?
  https://discourse.elm-lang.org/t/what-i-ve-learned-about-minifying-elm-code/7632
  look at esbuild
- put the target in dist
  - put the static sources in an assets dir and copy them into dist on build too- BadInputFromTypeScript -> I don't do anything if I can something bad from
- work out how I will handle changes to the settings file format
- Could I write a worker that keeps an eye on what is being edited and adds
  a completion timestamp when it is done?
- Settings to:
  - allow/deny directories/files
  - set max title lines
- I see that elm-ts-json now has a pipleline decoder - should switch to this as
  it makes decoders easier to read
- in the update for SettingsUpdated I am re-writing all markdown content and updating
  the hover for all edit buttons.  Can I be smarter?  Only matters really if performance
  issues.
- can I use github runners to build?
- run elm review
- where to use fuzz testing
- review awful typescript code!
- return something to elm if I fail to re-write a TODO due to the line having changed so I can
  let the user know why nothing has happened
- better parsing errors? - https://discourse.elm-lang.org/t/newline-and-indentation-issues-in-elm-parser/4869
- look into issue fixed in commit bca367 : TODO - why does this work....
  - can I get parser to always work when there is no "\n" on the end of the input
- if it is slow parsing vaults then see if I can speed it up by
  dropping backtrackable in the TaskItems parser.

api option for preview view so when given a block reference is still shows the whole document
but scrolls the block into view and highlights it.  When this is done I can use this when
hovering over the edit button to show the details of the todo in the original doc.  At the moment
if you do this, it will only show the single line of the todo and not any subtasks or content.

https://forum.obsidian.md/t/see-context-in-hover-preview-of-block-reference/10232
