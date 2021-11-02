module Model exposing
    ( EditState(..)
    , Model
    , addTaskList
    , cards
    , default
    , deleteItemsFromFile
    , finishAdding
    , forceAddWhenNoBoards
    , fromFlags
    , taskListLoaded
    , updateConfigs
    , updateTaskItems
    )

import BoardConfig exposing (BoardConfig)
import Card exposing (Card)
import CardBoardSettings
import InteropDefinitions
import Panels
import SafeZipper exposing (SafeZipper)
import State exposing (State)
import TaskList exposing (TaskList)
import Time
import TimeWithZone exposing (TimeWithZone)



-- TYPES


type alias Model =
    { boardConfigs : SafeZipper BoardConfig
    , configBeingEdited : EditState
    , taskList : State TaskList
    , timeWithZone : TimeWithZone
    }


type EditState
    = Adding (SafeZipper BoardConfig) BoardConfig
    | Deleting (SafeZipper BoardConfig)
    | Editing (SafeZipper BoardConfig)
    | NotEditing


default : Model
default =
    { boardConfigs = SafeZipper.empty
    , configBeingEdited = Adding SafeZipper.empty BoardConfig.default
    , taskList = State.Waiting
    , timeWithZone =
        { now = Time.millisToPosix 0
        , zone = Time.customZone 0 []
        }
    }


fromFlags : InteropDefinitions.Flags -> Model
fromFlags flags =
    let
        boardConfigs =
            SafeZipper.fromList <| CardBoardSettings.boardConfigs flags.settings
    in
    { boardConfigs = boardConfigs
    , configBeingEdited = NotEditing
    , taskList = State.Waiting
    , timeWithZone =
        { now = Time.millisToPosix flags.now
        , zone = Time.customZone flags.zone []
        }
    }
        |> forceAddWhenNoBoards boardConfigs



-- TASKLIST MANIPULATION


addTaskList : TaskList -> Model -> Model
addTaskList list model =
    case model.taskList of
        State.Waiting ->
            { model | taskList = State.Loading list }

        State.Loading currentList ->
            { model | taskList = State.Loading (TaskList.append currentList list) }

        State.Loaded currentList ->
            { model | taskList = State.Loaded (TaskList.append currentList list) }


deleteItemsFromFile : String -> Model -> Model
deleteItemsFromFile filePath model =
    case model.taskList of
        State.Waiting ->
            model

        State.Loading currentList ->
            { model | taskList = State.Loading (TaskList.removeForFile filePath currentList) }

        State.Loaded currentList ->
            { model | taskList = State.Loaded (TaskList.removeForFile filePath currentList) }


finishAdding : Model -> Model
finishAdding model =
    case model.taskList of
        State.Waiting ->
            { model | taskList = State.Loaded TaskList.empty }

        State.Loading list ->
            { model | taskList = State.Loaded list }

        State.Loaded _ ->
            model


updateTaskItems : String -> TaskList -> Model -> Model
updateTaskItems filePath updatedList model =
    case model.taskList of
        State.Waiting ->
            { model | taskList = State.Loading updatedList }

        State.Loading currentList ->
            { model | taskList = State.Loading (TaskList.replaceForFile filePath updatedList currentList) }

        State.Loaded currentList ->
            { model | taskList = State.Loaded (TaskList.replaceForFile filePath updatedList currentList) }



-- MISC


cards : Model -> List Card
cards model =
    model
        |> taskList
        |> Panels.init model.boardConfigs
        |> Panels.cards model.timeWithZone


forceAddWhenNoBoards : SafeZipper BoardConfig -> Model -> Model
forceAddWhenNoBoards config model =
    if SafeZipper.length config == 0 then
        { model | configBeingEdited = Adding config BoardConfig.default }

    else
        model


taskListLoaded : Model -> Bool
taskListLoaded model =
    State.hasLoaded model.taskList


updateConfigs : List BoardConfig -> Model -> Model
updateConfigs newConfigs model =
    case model.taskList of
        State.Waiting ->
            { model | boardConfigs = SafeZipper.fromList newConfigs }

        State.Loading _ ->
            { model | boardConfigs = SafeZipper.fromList newConfigs }

        State.Loaded _ ->
            let
                configs =
                    SafeZipper.fromList newConfigs
                        |> SafeZipper.atIndex newIndex

                newIndex =
                    model.boardConfigs
                        |> SafeZipper.currentIndex
                        |> Maybe.withDefault 0
            in
            { model | boardConfigs = configs }



-- HELPERS


taskList : Model -> TaskList
taskList model =
    case model.taskList of
        State.Waiting ->
            TaskList.empty

        State.Loading currentList ->
            currentList

        State.Loaded currentList ->
            currentList