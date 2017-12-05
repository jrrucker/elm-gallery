module Images.Utils exposing (..)

import Images.Models exposing (..)


getImage : ImageId -> List Image -> Maybe Image
getImage id images =
    images
        |> List.filter (\image -> image.id == id)
        |> List.head


getPerson : PersonId -> List Person -> Maybe Person
getPerson id allPeople =
    allPeople
        |> List.filter (\person -> person.id == id)
        |> List.head


getPeople : Image -> List Person -> List Person
getPeople image allPeople =
    List.filter (\person -> (List.member person.id image.people)) allPeople


getImagesOfPerson : PersonId -> List Image -> List Image
getImagesOfPerson personId allImages =
    List.filter (\image -> (List.member personId image.people)) allImages
