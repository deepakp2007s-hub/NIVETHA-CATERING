import { LoaderCircle } from "lucide-react";
import "./Loading.css";

export default function Loading({ message = "Preparing something delicious..." }) {
  return (
    <div className="nv-loading" role="status" aria-live="polite">
      <div className="nv-loading-mark">N</div>
      <LoaderCircle className="nv-loading-spinner" size={25} />
      <p>{message}</p>
    </div>
  );
}