module Page exposing (Page(..), PageState, fromRoute, jsUpdate, initialState, view)

import Page.Home as Home
import Page.Person as Person
import Page.Image as Image
import Page.PersonImage as PersonImage
import Routing exposing (Route(..))
import Images.Models exposing (Album, Layout)
import Html exposing (Html, div, text)
import Interop exposing (InMessage(..))


type Page
    = Home Home.Model
    | Person Person.Model
    | Image Image.Model
    | PersonImage PersonImage.Model
    | Blank


type PageState
    = Loaded Page
    | Transitioning Page Page


initialState : PageState
initialState =
    Loaded Blank


activePage : PageState -> Page
activePage pageState =
    case pageState of
        Loaded page ->
            page

        Transitioning old _ ->
            old


updatingPage : PageState -> Page
updatingPage pageState =
    case pageState of
        Transitioning _ newPage ->
            newPage

        Loaded page ->
            page


fromRoute : PageState -> Album -> Route -> ( PageState, Cmd msg )
fromRoute currentState album route =
    case route of
        HomeRoute ->
            (Home.init album)
                |> Tuple.mapFirst Home
                |> Tuple.mapFirst (Transitioning (activePage currentState))

        PersonRoute personId ->
            (Person.init album personId)
                |> Tuple.mapFirst Person
                |> Tuple.mapFirst (Transitioning (activePage currentState))

        ImageRoute imgId ->
            (Image.init imgId)
                |> Tuple.mapFirst Image
                |> Tuple.mapFirst Loaded

        PersonImageRoute imgId personId ->
            (PersonImage.init imgId personId)
                |> Tuple.mapFirst PersonImage
                |> Tuple.mapFirst Loaded

        NotFoundRoute ->
            ( Loaded Blank, Cmd.none )


jsUpdate : InMessage -> PageState -> PageState
jsUpdate msg pageState =
    case ( msg, pageState ) of
        ( HomeLayout layout, Transitioning _ (Home model) ) ->
            Loaded (Home (Home.setLayout model layout))

        ( PersonLayout layout, Transitioning _ (Person model) ) ->
            Loaded (Person (Person.setLayout model layout))

        ( _, _ ) ->
            pageState


view : PageState -> Album -> Html msg
view pageState album =
    case (activePage pageState) of
        Home model ->
            Home.view album model

        Person model ->
            Person.view album model

        Image model ->
            Image.view album model

        PersonImage model ->
            PersonImage.view album model

        Blank ->
            div [] [ text "blank" ]
