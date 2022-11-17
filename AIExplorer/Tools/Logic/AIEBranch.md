#  Branch

The branch node allows you to assign a condition to control the flow through the neural network. Note that the number of options for the node are somewhat limited.

## Conditions

For each exit link from the branch node, you'll get an inspector field where you can select a variable defined in the document. You can select either the positive or negative case of the variable. Currently, the condition is limited to simple variables. This may expand in the future.

To get a variable, you can define the variable on the node itself, on the node's enclosing group, if it has one, or on the node's page or document. By default, the document predefines one useful variable, `isTraining`.


