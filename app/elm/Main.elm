module Main exposing (..)

import Navigation exposing (Location)
import View exposing (..)
import Commands exposing (loadImages, loadPeople)
import Routing exposing (Route, parseLocation)
import RemoteData exposing (WebData)
import Html exposing (Html, div)
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
            Routing.ImageRoute id ->
                combinedRequests
                    |> RemoteData.map (Tuple.mapFirst (getImage id))
                    |> remoteDataView
                        (\( maybeImage, allPeople ) ->
                            case maybeImage of
                                Just image ->
                                    imageView image (getPeople image allPeople)

                                Nothing ->
                                    imageNotFoundView
                        )

            Routing.PersonRoute id ->
                combinedRequests
                    |> RemoteData.map (Tuple.mapSecond (getPerson id))
                    |> remoteDataView
                        (\( allImages, maybePerson ) ->
                            case maybePerson of
                                Just person ->
                                    galleryView (getImagesOfPerson person allImages)

                                Nothing ->
                                    personNotFoundView
                        )

            Routing.HomeRoute ->
                remoteDataView galleryView model.allImages

            Routing.PersonNotFound ->
                personNotFoundView

            Routing.ImageNotFound ->
                imageNotFoundView

            Routing.NotFoundRoute ->
                (notFoundView "Page not found")



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
