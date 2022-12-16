type AnnotationJobDb = {
    id: string,
    CreatedOn: string,
    ImageUriOriginal: string

    ImageUriThumbnail: string
}

type AnnotationDb = {
    id: string,
    AnnotatedOn: string,
    ServerReceivedOn: string,
    AnnotationJobId: string,
    BoundingBoxes: string,
}

export type {AnnotationJobDb, AnnotationDb};