module Main exposing (..)

import Navigation exposing (Location)
import View exposing (..)
import Commands exposing (loadImages, loadPeople)
import Routing exposing (Route, parseLocation)
import RemoteData exposing (WebData, RemoteData(..))
import Html exposing (Html, div, text)
import Images.Models exposing (Image, Person, Album)
import Interop exposing (InMessage)
import Task
import Page exposing (Page, PageState)
import Window exposing (..)


main : Program Never Model Msg
main =
    Navigation.program (Routing.parseLocation >> OnRouteChange)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { route : Route
    , album : WebData Album
    , pageState : PageState
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        initialRoute =
            Routing.parseLocation location

        albumPath =
            case (String.split "=" location.search) of
                [ "?album", name ] ->
                    name

                _ ->
                    ""
    in
        ( { route = initialRoute
          , album = Loading
          , pageState = Page.initialState
          }
        , loadAlbum albumPath
        )


loadAlbum : String -> Cmd Msg
loadAlbum albumPath =
    Task.map2 Album
        (loadImages albumPath)
        (loadPeople albumPath)
        |> RemoteData.asCmd
        |> Cmd.map AlbumLoaded



-- Update


type Msg
    = OnRouteChange Route
    | AlbumLoaded (WebData Album)
    | JsMessage InMessage
    | Resize

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.album of
        RemoteData.Success album ->
            loadedUpdate msg model album

        _ ->
            loadingUpdate msg model


loadedUpdate : Msg -> Model -> Album -> ( Model, Cmd Msg )
loadedUpdate msg model album =
    case msg of
        OnRouteChange route ->
            let
                ( newState, cmd ) =
                    Page.fromRoute model.pageState album route
            in
                ( { model
                    | pageState = newState
                    , route = route
                  }
                , cmd
                )

        JsMessage jsMessage ->
            ( { model
                | pageState = Page.jsUpdate jsMessage model.pageState
              }
            , Cmd.none
            )

        Resize -> 
            let
                ( newState, cmd ) =
                    Page.fromRoute model.pageState album model.route
            in
                ( model
                , cmd
                )

        _ ->
            ( model, Cmd.none )


loadingUpdate : Msg -> Model -> ( Model, Cmd Msg )
loadingUpdate msg model =
    case msg of
        AlbumLoaded loadState ->
            case loadState of
                RemoteData.Success album ->
                    let
                        ( newPageState, cmd ) =
                            Page.fromRoute model.pageState album model.route
                    in
                        ( { model
                            | pageState = newPageState
                            , album = loadState
                          }
                        , cmd
                        )

                _ ->
                    ( { model | album = loadState }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )



-- View


notFoundView : Html msg
notFoundView =
    div []
        [ text "Page not found." ]


view : Model -> Html Msg
view model =
    div []
        [ case model.album of
            NotAsked ->
                loadingView

            Loading ->
                loadingView

            Success album ->
                Page.view model.pageState album

            Failure error ->
                errorView error
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Interop.recieve JsMessage
        , Window.resizes (\{height, width} -> Resize)
        ]
