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


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
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
    = OnLocationChange Location
    | AlbumLoaded (WebData Album)
    | JsMessage InMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.album of
        RemoteData.Success album ->
            case msg of
                OnLocationChange location ->
                    let
                        route =
                            parseLocation location

                        ( newState, cmd ) =
                            Page.fromRoute model.pageState album route
                    in
                        ( { model
                            | pageState = newState
                          }
                        , cmd
                        )

                JsMessage jsMessage ->
                    case jsMessage of
                        Interop.Unknown ->
                            ( model, Cmd.none )

                        _ ->
                            let
                                newPageState =
                                    Page.setLayout jsMessage model.pageState
                            in
                                ( { model
                                    | pageState = newPageState
                                  }
                                , Cmd.none
                                )

                _ ->
                    ( model, Cmd.none )

        _ ->
            case msg of
                AlbumLoaded loadState ->
                    let
                        loadingUpdated =
                            { model | album = loadState }
                    in
                        case loadState of
                            RemoteData.Success album ->
                                let
                                    ( newPageState, cmd ) =
                                        Page.fromRoute model.pageState album model.route
                                in
                                    ( { loadingUpdated
                                        | pageState = newPageState
                                      }
                                    , cmd
                                    )

                            _ ->
                                ( loadingUpdated, Cmd.none )

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
    Interop.recieve JsMessage
