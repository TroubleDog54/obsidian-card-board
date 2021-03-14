module TaskItems exposing
    ( completed
    , forFuture
    , forToday
    , forTomorrow
    , parser
    , undated
    )

import Date exposing (Date)
import Parser exposing (..)
import ParserHelper exposing (anyLineParser)
import TaskItem exposing (Dated(..), TaskItem)



-- PARSEING


parser : String -> Maybe String -> Parser (List TaskItem)
parser filePath fileDate =
    loop [] (taskItemsHelp filePath fileDate)



-- FILTERS


undated : List TaskItem -> List TaskItem
undated =
    List.filter (\t -> (not <| TaskItem.isCompleted t) && (not <| TaskItem.isDated t))


forToday : Date -> List TaskItem -> List TaskItem
forToday today =
    let
        isToday t =
            case TaskItem.due t of
                Nothing ->
                    False

                Just date ->
                    if Date.diff Date.Days today date <= 0 then
                        True

                    else
                        False
    in
    List.filter (\t -> (not <| TaskItem.isCompleted t) && isToday t)


forTomorrow : Date -> List TaskItem -> List TaskItem
forTomorrow today =
    let
        tomorrow =
            Date.add Date.Days 1 today

        isTomorrow t =
            case TaskItem.due t of
                Nothing ->
                    False

                Just date ->
                    if Date.diff Date.Days tomorrow date == 0 then
                        True

                    else
                        False
    in
    List.filter (\t -> isTomorrow t && (not <| TaskItem.isCompleted t))


forFuture : Date -> List TaskItem -> List TaskItem
forFuture today =
    let
        tomorrow =
            Date.add Date.Days 1 today

        isToday t =
            case TaskItem.due t of
                Nothing ->
                    False

                Just date ->
                    if Date.diff Date.Days tomorrow date > 0 then
                        True

                    else
                        False
    in
    List.filter (\t -> (not <| TaskItem.isCompleted t) && isToday t)


completed : List TaskItem -> List TaskItem
completed =
    List.filter (\t -> TaskItem.isCompleted t)



-- PRIVATE


taskItemsHelp : String -> Maybe String -> List TaskItem -> Parser (Step (List TaskItem) (List TaskItem))
taskItemsHelp filePath fileDate revTaskItems =
    oneOf
        [ TaskItem.parser filePath fileDate
            |> map (\taskItem -> Loop (taskItem :: revTaskItems))
        , anyLineParser
            |> map (\_ -> Loop revTaskItems)
        , succeed ()
            |> map (\_ -> Done (List.reverse revTaskItems))
        ]
