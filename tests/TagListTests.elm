module TagListTests exposing (suite)

import Expect
import Parser
import Tag exposing (Tag)
import TagList exposing (TagList)
import Test exposing (..)


suite : Test
suite =
    concat
        [ empty
        , push
        , append
        , fromList
        , isEmpty
        , containsTagMatchingBasic
        , containsTagMatchingSubtag
        , containsTagMatchingSubtagWildcard
        , containsTagMatchingOneOf
        ]


empty : Test
empty =
    describe "empty"
        [ test "contains no Tags" <|
            \() ->
                TagList.empty
                    |> TagList.toString
                    |> Expect.equal ""
        ]


push : Test
push =
    describe "push"
        [ test "can push a Tag onto an empty TagList" <|
            \() ->
                TagList.empty
                    |> pushTag (buildTag "foo")
                    |> TagList.toString
                    |> Expect.equal "#foo"
        , test "can push multiple Tags onto an empty TagList" <|
            \() ->
                TagList.empty
                    |> pushTag (buildTag "foo")
                    |> pushTag (buildTag "bar")
                    |> pushTag (buildTag "baz")
                    |> TagList.toString
                    |> Expect.equal "#foo #bar #baz"
        ]


append : Test
append =
    describe "append"
        [ test "appending two empty TagLists produces and emptu TagList" <|
            \() ->
                TagList.empty
                    |> TagList.append TagList.empty
                    |> TagList.toString
                    |> Expect.equal ""
        , test "appending an empty TagList onto a non-empty one gives the non-empty one" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.append TagList.empty
                    |> TagList.toString
                    |> Expect.equal "#foo #bar"
        , test "puts two TagLists together" <|
            \() ->
                TagList.fromList [ "baz", "quz" ]
                    |> TagList.append (TagList.fromList [ "foo", "bar" ])
                    |> TagList.toString
                    |> Expect.equal "#foo #bar #baz #quz"
        ]


fromList : Test
fromList =
    describe "fromList"
        [ test "builds an empty TagList from an empty list" <|
            \() ->
                TagList.fromList []
                    |> TagList.isEmpty
                    |> Expect.equal True
        , test "builds the TagList from the list" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.toString
                    |> Expect.equal "#foo #bar"
        , test "ignores invalid tags" <|
            \() ->
                TagList.fromList [ "!@#", "foo", "123", "bar", "", "#plop" ]
                    |> TagList.toString
                    |> Expect.equal "#foo #bar"
        ]


isEmpty : Test
isEmpty =
    describe "isEmpty"
        [ test "returns True for an empty TagList" <|
            \() ->
                TagList.empty
                    |> TagList.isEmpty
                    |> Expect.equal True
        , test "returns False for a non-empty TagList" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.isEmpty
                    |> Expect.equal False
        ]


containsTagMatchingBasic : Test
containsTagMatchingBasic =
    describe "containsTagMatching - basic"
        [ test "returns True if the TagList contains an exact match" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.containsTagMatching "foo"
                    |> Expect.equal True
        , test "is case insensative" <|
            \() ->
                TagList.fromList [ "foO", "bar" ]
                    |> TagList.containsTagMatching "Foo"
                    |> Expect.equal True
        , test "returns False if the TagList does NOT contain the tag" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.containsTagMatching "baz"
                    |> Expect.equal False
        , test "returns False if the TagList is empty" <|
            \() ->
                TagList.empty
                    |> TagList.containsTagMatching "bar"
                    |> Expect.equal False
        , test "returns False if the TagList and the match are empty" <|
            \() ->
                TagList.empty
                    |> TagList.containsTagMatching ""
                    |> Expect.equal False
        , test "returns False if the TagList contains a tag that starts with the match" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.containsTagMatching "fo"
                    |> Expect.equal False
        , test "returns False if the TagList contains the tag but it is followed  by a '/'" <|
            \() ->
                TagList.fromList [ "foo/", "bar" ]
                    |> TagList.containsTagMatching "foo"
                    |> Expect.equal False
        , test "returns False if the TagList contains the tag but it is followed  by a subtag" <|
            \() ->
                TagList.fromList [ "foo/baz", "bar" ]
                    |> TagList.containsTagMatching "foo"
                    |> Expect.equal False
        ]


containsTagMatchingSubtag : Test
containsTagMatchingSubtag =
    describe "containsTagMatching - subtags"
        [ test "returns True if the TagList contains an exact match" <|
            \() ->
                TagList.fromList [ "foo", "bar/baz" ]
                    |> TagList.containsTagMatching "bar/baz"
                    |> Expect.equal True
        , test "returns False if the TagList contains the tag/subtag but it has a trailing '/'" <|
            \() ->
                TagList.fromList [ "foo", "bar/baz/" ]
                    |> TagList.containsTagMatching "bar/baz"
                    |> Expect.equal False
        , test "only matches actual subtags" <|
            \() ->
                TagList.fromList [ "foo", "bart" ]
                    |> TagList.containsTagMatching "bar/"
                    |> Expect.equal False
        ]


containsTagMatchingSubtagWildcard : Test
containsTagMatchingSubtagWildcard =
    describe "containsTagMatching - subtag wildcards"
        [ test "returns True if the TagList contains an exact match" <|
            \() ->
                TagList.fromList [ "foo", "bar/" ]
                    |> TagList.containsTagMatching "bar/"
                    |> Expect.equal True
        , test "returns True if the TagList contains the tag with a subtag" <|
            \() ->
                TagList.fromList [ "foo", "bar/baz" ]
                    |> TagList.containsTagMatching "bar/"
                    |> Expect.equal True
        ]


containsTagMatchingOneOf : Test
containsTagMatchingOneOf =
    describe "containsTagMatchingOneOf"
        [ test "returns True if the TagList contains a matching tag" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.containsTagMatchingOneOf [ "bar", "baz" ]
                    |> Expect.equal True
        , test "returns False if the TagList does NOT contain a matching tag" <|
            \() ->
                TagList.fromList [ "foo", "bar" ]
                    |> TagList.containsTagMatchingOneOf [ "baz", "qux" ]
                    |> Expect.equal False
        ]



-- HELPERS


buildTag : String -> Maybe Tag
buildTag content =
    ("#" ++ content)
        |> Parser.run Tag.parser
        |> Result.toMaybe


pushTag : Maybe Tag -> TagList -> TagList
pushTag tag list =
    tag
        |> Maybe.map (\t -> TagList.push t list)
        |> Maybe.withDefault TagList.empty
