module TaskPaperTag exposing (autodoneTagParser, doneTagParser, dueTagParser, parser)

import Date exposing (Date)
import Parser as P exposing ((|.), (|=), Parser)
import ParserHelper exposing (checkWhitespaceFollows)
import Time



-- PARSER


autodoneTagParser : (Bool -> a) -> Parser a
autodoneTagParser =
    parser "autodone" ParserHelper.booleanParser


doneTagParser : (Time.Posix -> a) -> Parser a
doneTagParser =
    parser "done" ParserHelper.timeParser


dueTagParser : (Date -> a) -> Parser a
dueTagParser =
    parser "due" ParserHelper.dateParser


parser : String -> Parser a -> (a -> b) -> Parser b
parser tagKeyword valueParser tagger =
    tagParser tagKeyword valueParser tagger
        |> checkWhitespaceFollows



-- PRIVATE


tagParser : String -> Parser a -> (a -> b) -> Parser b
tagParser tagKeyword valueParser tagger =
    P.succeed tagger
        |. P.token ("@" ++ tagKeyword ++ "(")
        |= valueParser
        |. P.token ")"
