module Main exposing (..)

import Navigation exposing (Location)
import View exposing (..)
import Images.GalleryView exposing (galleryView)
import Commands exposing (loadImages, loadPeople)
import Routing exposing (Route, parseLocation)
import RemoteData exposing (WebData, RemoteData(..))
import Html exposing (Html, div, text)
import Images.Models exposing (Image, Person, Album)
import Images.ImageView exposing (imageView)
import Task


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            ( { model | route = parseLocation location }
            , Cmd.none
            )

        AlbumLoaded response ->
            ( { model | album = response }, Cmd.none )



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
                pageView model.route album

            Failure error ->
                errorView error
        ]


pageView : Route -> Album -> Html msg
pageView route album =
    case route of
        Routing.ImageRoute imageId ->
            imageView Maybe.Nothing imageId album

        Routing.PersonRoute personId ->
            galleryView (Maybe.Just personId) album

        Routing.HomeRoute ->
            galleryView Maybe.Nothing album

        Routing.PersonImageRoute personId imageId ->
            imageView (Maybe.Just personId) imageId album

        Routing.NotFoundRoute ->
            notFoundView



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
