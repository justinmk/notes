TODO:
- Andrej Karpathy "Let's build GPT: from scratch, in code, spelled out." https://youtu.be/kCc8FmEb1nY
- https://course.fast.ai/
- https://mlu-explain.github.io/


Neural networks, LLMS
--------------------------------------------------------------------------------

LLM visualization: https://bbycroft.net/llm

- https://x.com/karpathy/status/1835024197506187617
  "Language" in the name LLM is just historical. They are highly general-purpose
  technology for statistical modeling of *token streams*. Tokens can represent
  text chunks. It could just as well be little image patches, audio chunks,
  action choices, molecules, or whatever.
    - Caveat: https://x.com/ylecun/status/1835303018914324689
      > Auto-regressive prediction for things that are not temporal sequences
      > (with some temporal causality) is a pure abomination. Even for temporal
      > sequences, auto-regression *in input space* is inferior to
      > auto-regression in representation space: a dynamics is not necessarily
      > represented efficiently by a sequence of past inputs.

- vector vs embedding:
    - Vectors are a general mathematical construct (list of numbers).
    - Embeddings are a particular kind of lower-dimensional vector "learned" by
      neural networks, optimized to represent semantic relationships between
      discrete objects like words. The network learns embeddings that _capture
      similarities_ between objects.
    - Vectors encode individual objects, while embeddings encode relationships
      between objects. The distances between embedded objects have meaning.
      Objects close together are semantically similar.
    - Vectors have fixed lengths, like 300 dims. Embeddings are usually lower
      dimensional, like 50-100 dims, as the model learns to efficiently encode
      objects.
    - Vectors are static representations, while embeddings are optimized during
      training to improve their encoding of relationships.


- GPT = generative pretrained transformer
    - "transformer": marketing name for "attention net"
        - Detects subtle relationships amongst even distant data elements in a sequence.
        - "self-attention": differentially weighting each part of the input (which includes recursive output).
        - KEY IDEA: Unlike traditional neural networks with fixed weights,
          self-attention layers adaptively weight connections between inputs
          based on context. Allows transformers to accomplish in a single layer
          what would take traditional networks multiple layers.
        - From 2017 Google paper
          https://ai.googleblog.com/2017/08/transformer-novel-neural-network.html
          https://arxiv.org/abs/1706.03762
    - Trained by RLHF
      https://en.wikipedia.org/wiki/Reinforcement_learning_from_human_feedback


Deep learning
--------------------------------------------------------------------------------

https://news.ycombinator.com/item?id=14485362
    > You don’t need Google-scale data to use deep learning. Using all of the above
    > means that even your average person with only a 100-1000 samples can see some
    > benefit from deep learning. With all of these techniques you can mitigate the
    > variance issue, while still benefitting from the flexibility.
    |
    └─  _Transfer Learning_
        "Easiest way to use deep learning without a lot of data: download
        a pretrained model and fine-tune the last few layers on your small
        dataset. In many domains (like image classification) fine-tuning works
        extremely well, because the pretrained model has learned generic
        features in the early layers that are useful for many datasets, not
        just the one trained on. Even the best skin cancer classifier
        (http://www.nature.com/articles/nature21056) was pretrained on ImageNet.
        |
        └─ "This is how the great http://course.fast.ai course begins - download VGG16,
        |   finetune the top layer with a single dense layer, get amazing results.
        |
        └─ Remove the last "layer" of the neural net. Then you can use
           a classifier (e.g. SVM) to add the layer back, for your specific
           application. E.g. with deep learning, the NN finds features, these
           are in the last "hidden layer". That layer is generalized, you can
           use those features to train for your specific application.

