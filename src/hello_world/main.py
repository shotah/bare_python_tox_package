"""Hello World main module."""


def hello_world() -> str:
    """Return a hello world message.

    Returns:
        str: A friendly greeting.
    """
    return "Hello, World!"


def greet(name: str) -> str:
    """Return a personalized greeting.

    Args:
        name: The name to greet.

    Returns:
        str: A personalized greeting message.
    """
    return f"Hello, {name}!"


def main() -> None:
    """Entry point for the package."""
    print(hello_world())


if __name__ == "__main__":
    main()
