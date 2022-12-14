-- This isn't used anymore, since we can easily create jobs and annotations inside the app.
-- Annotation jobs data
INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("892461f6-b00a-469f-9fd1-42c71bc0fe00", '20221206 10:00:00', "rodrigo-dos-reis-DkTuGvgPotA-unsplash.jpg");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("ce52db24-aa55-45c2-bf1a-4c93b3c0eb61", '20221206 11:00:00', "eiliv-aceron-k9X5yGle-NA-unsplash.jpg");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("5be43825-9ae9-457f-82e6-b32fdc7531f7", '20221206 12:00:00', "IMG_4004.jpg");

-- Annotation data
INSERT INTO Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) VALUES (
    "3ed3397f-6a7d-4cb3-a260-f935151dc95b", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", '[{"topLeft":{"dx":10.0,"dy":10.0},"size":{"width":100.0,"height":50.0}}]'
),(
    "3ed3397f-6a7d-4cb3-a260-f935151dc95c", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", "[]"
),(
    "3ed3397f-6a7d-4cb3-a260-f935151dc95d", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", '[{"topLeft":{"dx":10.0,"dy":10.0},"size":{"width":100.0,"height":50.0}}]'
);
