module Main exposing (Model, Msg(..), init, loadAlbum, loadedUpdate, loadingUpdate, main, notFoundView, subscriptions, update, view)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as Nav exposing (Key)
import Commands exposing (loadImages, loadPeople)
import Html exposing (Html, div, text)
import Images.Models exposing (Album, Image, Person)
import Interop exposing (InMessage)
import Page exposing (Page, PageState)
import RemoteData exposing (RemoteData(..), WebData)
import Routing exposing (Route, parseLocation)
import Task
import Url exposing (Url)
import Url.Parser exposing (parse, query)
import Url.Parser.Query as Query
import View exposing (..)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = onUrlChange
        }



-- Model


type alias Model =
    { route : Route
    , album : WebData Album
    , pageState : PageState
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ location key =
    let
        initialRoute =
            Routing.parseLocation location

        albumParser =
            Query.string "album"
                |> Query.map (Maybe.withDefault "")
                |> query

        albumPath =
            parse albumParser location
                |> Maybe.withDefault ""
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
    | ClickedLink UrlRequest


onUrlChange : Url -> Msg
onUrlChange url =
    OnRouteChange (Routing.parseLocation url)


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
              }
            , cmd
            )

        ClickedLink request ->
            case request of
                Internal url ->
                    ( model, Nav.load (Url.toString url) )

                External url ->
                    ( model, Nav.load url )

        JsMessage jsMessage ->
            ( { model
                | pageState = Page.jsUpdate jsMessage model.pageState
              }
            , Cmd.none
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


body : Model -> Html Msg
body model =
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


view : Model -> Document Msg
view model =
    { title = "Elm-Gallery"
    , body = [ body model ]
    }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Interop.recieve JsMessage
