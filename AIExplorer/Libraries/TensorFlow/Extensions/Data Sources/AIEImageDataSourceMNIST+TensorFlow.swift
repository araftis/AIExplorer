//
//  AIEImageDataSourceMNIST+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import Foundation

extension AIEImageDataSourceMNIST : AIETensorFlowCodeWriter {

    internal func generateInitializationCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeIndented("self.dataset_train = None\n")
        try context.writeIndented("self.dataset_test = None\n")
        try context.writeIndented("self.dataset_info = None\n")
        try context.writeIndented("self.dataset = None\n")
        return true
    }

    internal func generatePrepareDataset(context: AIETensorFlowContext) throws -> Void {
        try context.write("\n")
        try context.writeFunction(name: "def prepare_data_source", indented: true) {
            try context.writeArgument("self")
        } body: {
            try context.writeIndented("""
                # Fetch and "format" the data
                (ds_train, ds_test), ds_info = tfds.load(
                    'mnist',
                    split=['train', 'test'],
                    shuffle_files=True,
                    as_supervised=True,
                    with_info=True,
                )
                self.dataset_info = ds_info
                """)
            
            try context.write("\n")
            try context.writeIndented("# A useful little function to normalize the data's values from 0-255 to 0.0 to 1.0.\n")
            try context.writeFunction(name: "def normalize_img", indented: true, suffix: ":\n") {
                try context.writeArgument("image")
                try context.writeArgument("label")
            }
            try context.indent {
                //try context.writeIndented("\"\"\"Normalizes images: `uint8` -> `float32`.\"\"\"\n")
                try context.writeIndented("return tf.cast(image, tf.float32) / 255.0, label\n")
            }
            try context.write("\n")
            try context.writeIndented("""
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
            try context.writeIndented("""
                # Normalize and prepare the testing data.
                ds_test = ds_test.map(normalize_img, num_parallel_calls=tf.data.AUTOTUNE)
                ds_test = ds_test.batch(128)
                ds_test = ds_test.cache()
                ds_test = ds_test.prefetch(tf.data.AUTOTUNE)
                self.dataset_test = ds_test
                """
            )
            try context.write("\n")
            try context.writeIndented("# Make sure the dataset is None, because we're not using it.\n")
            try context.writeIndented("\nself.dataset = None\n")
        }
    }
    
    internal func generatePropertyGetters(context: AIETensorFlowContext) throws -> Void {
        try context.write("\n")
        try context.writeFunction(name: "def get_dataset_info", indented: true) {
            try context.writeArgument("self")
        } body: {
            try context.writeIndented("self.prepare_data_source()\n")
            try context.writeIndented("return self.dataset_info\n")
        }
        try context.write("\n")
        try context.writeFunction(name: "def get_dataset_train", indented: true) {
            try context.writeArgument("self")
        } body: {
            try context.writeIndented("self.prepare_data_source()\n")
            try context.writeIndented("return self.dataset_train\n")
        }
        try context.write("\n")
        try context.writeFunction(name: "def get_dataset_test", indented: true) {
            try context.writeArgument("self")
        } body: {
            try context.writeIndented("self.prepare_data_source()\n")
            try context.writeIndented("return self.dataset_test\n")
        }
    }
    
    internal func generateMethodsCode(context: AIETensorFlowContext) throws -> Bool {
        try generatePrepareDataset(context: context)
        try generatePropertyGetters(context: context)
        return true
    }
    
    func generateCode(context: AIETensorFlowContext) throws -> Bool {
        return false
    }
    
    var license: String? {
        return """
            MNIST License:
            
            Yann LeCun and Corinna Cortes hold the copyright of MNIST dataset, which is a derivative work from original NIST datasets. MNIST dataset is made available under the terms of the [Creative Commons Attribution-Share Alike 3.0 license.](https://creativecommons.org/licenses/by-sa/3.0/)
            """
    }
    
    var destinationObjects: [AIEGraphic] {
        return []
    }
    
    var variableName: String {
        return "dataSource"
    }
    
    var inputShape: [Int]? {
        return nil
    }
    
    var outputShape: [Int] {
        return []
    }
    
    var kind: AIEGraphic.Kind {
        return .support
    }
    
}
