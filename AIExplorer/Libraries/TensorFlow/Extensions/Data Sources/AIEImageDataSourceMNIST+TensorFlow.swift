//
//  AIEImageDataSourceMNIST+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import Foundation

extension AIEImageDataSourceMNIST : AIETensorFlowCodeWriter {
    
    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowMNISTWriter(object: self)
    }
    
    internal class AIETensorFlowMNISTWriter : AIETypedCodeWriter<AIEImageDataSourceMNIST> {
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            try context.write("self.dataset_train = None\n")
            try context.write("self.dataset_test = None\n")
            try context.write("self.dataset_info = None\n")
            try context.write("self.dataset = None\n")
            return true
        }
        
        func generatePrepareDataset(context: AIECodeGeneratorContext) throws -> Void {
            try context.write("\n")
            let documentation = """
                Prepares the data for training. You don't need to call this if you're just going to load the model and then use inference.
                
                In this case, this will download the MNIST data, if it's not already been downloaded, load it, and then normalize the data. Normalization is done by converting the data from gray scale values of 0 to 255 to values of 0.0 to 1.0.
                """
            try context.writeFunction(name: "prepare_data_source", type: .implementation, documentation: documentation) {
                try context.writeArgument("self")
            } body: {
                try context.write("""
                    # Fetch and "format" the data
                    (ds_train, ds_test), ds_info = tfds.load(
                        'mnist',
                        split=['train', 'test'],
                        shuffle_files=True,
                        as_supervised=True,
                        with_info=True,
                    )
                    self.dataset_info = ds_info\n
                    """)
                
                try context.write("\n")
                try context.write("# A useful little function to normalize the data's values from 0-255 to 0.0 to 1.0.\n")
                try context.writeFunction(name: "normalize_img", type: .implementation) {
                    try context.writeArgument("image")
                    try context.writeArgument("label")
                }
                try context.indent {
                    //try context.write("\"\"\"Normalizes images: `uint8` -> `float32`.\"\"\"\n")
                    try context.write("return tf.cast(image, tf.float32) / 255.0, label\n")
                }
                try context.write("\n")
                try context.write("""
                    # Normalize and prepare the training data.
                    ds_train = ds_train.map(normalize_img, num_parallel_calls=tf.data.AUTOTUNE)
                    ds_train = ds_train.cache()
                    ds_train = ds_train.shuffle(ds_info.splits['train'].num_examples)
                    ds_train = ds_train.batch(128)
                    ds_train = ds_train.prefetch(tf.data.AUTOTUNE)
                    self.dataset_train = ds_train\n
                    """
                    )
                    try context.write("\n")
                    try context.write("""
                    # Normalize and prepare the testing data.
                    ds_test = ds_test.map(normalize_img, num_parallel_calls=tf.data.AUTOTUNE)
                    ds_test = ds_test.batch(128)
                    ds_test = ds_test.cache()
                    ds_test = ds_test.prefetch(tf.data.AUTOTUNE)
                    self.dataset_test = ds_test\n
                    """
                )
                try context.write("\n")
                try context.writeComment("Make sure the dataset is None, because we're not using it.\n", type: .singleLine)
                try context.write("\nself.dataset = None\n")
            }
        }
        
        func generatePropertyGetters(context: AIECodeGeneratorContext) throws -> Void {
            try context.write("\n")
            try context.writeFunction(name: "get_dataset_info", type: .implementation) {
                try context.writeArgument("self")
            } body: {
                try context.write("self.prepare_data_source()\n")
                try context.write("return self.dataset_info\n")
            }
            try context.write("\n")
            try context.writeFunction(name: "get_dataset_train", type: .implementation) {
                try context.writeArgument("self")
            } body: {
                try context.write("self.prepare_data_source()\n")
                try context.write("return self.dataset_train\n")
            }
            try context.write("\n")
            try context.writeFunction(name: "get_dataset_test", type: .implementation) {
                try context.writeArgument("self")
            } body: {
                try context.write("self.prepare_data_source()\n")
                try context.write("return self.dataset_test\n")
            }
        }
        
        override func generateImplementationMethodsCode(in context: AIECodeGeneratorContext) throws -> Bool {
            try generatePrepareDataset(context: context)
            try generatePropertyGetters(context: context)
            return true
        }
        
        override func license(context: AIECodeGeneratorContext) -> String? {
            return """
                MNIST License:
                
                Yann LeCun and Corinna Cortes hold the copyright of MNIST dataset, which is a derivative work from original NIST datasets. MNIST dataset is made available under the terms of the [Creative Commons Attribution-Share Alike 3.0 license.](https://creativecommons.org/licenses/by-sa/3.0/)
                """
        }
        
        override func imports(context: AIECodeGeneratorContext) -> [String] {
            return ["import tensorflow_datasets as tfds"]
        }
        
    }
    
}
