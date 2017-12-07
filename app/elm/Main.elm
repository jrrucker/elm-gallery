module Main exposing (..)

import Navigation exposing (Location)
import View exposing (..)
import Images.GalleryView exposing (galleryView)
import Commands exposing (loadImages, loadPeople)
import Routing exposing (Route, parseLocation)
import RemoteData exposing (WebData)
import Html exposing (Html, div, text)
import Images.Models exposing (Image, Person)
import Images.ImageView exposing (imageView)


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
    , allImages : WebData (List Image)
    , allPeople : WebData (List Person)
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , allImages = RemoteData.NotAsked
    , allPeople = RemoteData.NotAsked
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel currentRoute
        , Cmd.batch
            [ loadImages OnLoadImages
            , loadPeople OnLoadPeople
            ]
        )



-- Update


type Msg
    = OnLocationChange Location
    | OnLoadImages (WebData (List Image))
    | OnLoadPeople (WebData (List Person))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        OnLoadImages response ->
            ( { model | allImages = response }, Cmd.none )

        OnLoadPeople response ->
            ( { model | allPeople = response }, Cmd.none )



-- View


notFoundView : Html msg
notFoundView =
    div []
        [ text "Page not found." ]


view : Model -> Html Msg
view model =
    div []
        [ pageView model ]


pageView : Model -> Html msg
pageView model =
    let
        combinedRequests =
            RemoteData.append model.allImages model.allPeople
    in
        case model.route of
            Routing.ImageRoute imageId ->
                combinedRequests
                    |> remoteDataView (imageView Maybe.Nothing imageId)

            Routing.PersonRoute personId ->
                combinedRequests
                    |> remoteDataView (galleryView (Maybe.Just personId))

            Routing.HomeRoute ->
                combinedRequests
                    |> remoteDataView (galleryView Maybe.Nothing)

            Routing.PersonImageRoute personId imageId ->
                combinedRequests
                    |> remoteDataView (imageView (Maybe.Just personId) imageId)

            Routing.NotFoundRoute ->
                notFoundView



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
