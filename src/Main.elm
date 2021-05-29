module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, span, text)
import Html.Events exposing (onClick)
import Http
import List.Extra exposing (remove)
import Styles exposing (defaultFontFamily, defaultMargin, primaryButton, styleList, styleRow)



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = \_ -> Sub.none }



-- MODEL


type alias Model =
    List String


init : () -> ( Model, Cmd Msg )
init _ =
    ( []
    , Cmd.none
    )



-- UPDATE


type Msg
    = AddTask String
    | CompleteTask String
    | SendHttpRequest
    | TasksReceived (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask task ->
            ( model ++ [ task ], Cmd.none )

        CompleteTask task ->
            ( remove task model, Cmd.none )

        SendHttpRequest ->
            ( model, getTasks )

        TasksReceived (Ok tasks) ->
            let
                newTasks =
                    String.split "," tasks
            in
            ( model ++ newTasks, Cmd.none )

        TasksReceived (Err httpError) ->
            ( model, Cmd.none )


getTasks : Cmd Msg
getTasks =
    Http.get
        { url = "http://localhost:8080/usertasks"
        , expect = Http.expectString TasksReceived
        }



-- VIEW


view : Model -> Html Msg
view model =
    div [ defaultFontFamily, defaultMargin ]
        [ h1 [] [ text "Usertasks" ]
        , div styleList
            (List.map
                taskView
                model
            )
        , button ( primaryButton ++ [onClick SendHttpRequest] )
            [ text "Get data from server" ]
        ]


taskView : String -> Html Msg
taskView task =
    div (styleRow ++ [ onClick (CompleteTask task) ])
        [ span styleRow [ text task ] ]
